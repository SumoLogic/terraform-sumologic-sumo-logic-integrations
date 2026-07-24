package elb

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"strings"
	"testing"
	"time"

	aws_sdk "github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"

	"github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/terratest/common"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

var IAM_ROLE = os.Getenv("IAM_ROLE")
var COLLECTOR_ID = os.Getenv("COLLECTOR_ID")

func SetUpTest(t *testing.T, vars map[string]interface{}, awsregion string) (*terraform.Options, *terraform.ResourceCount) {
	envVars := map[string]string{
		"AWS_DEFAULT_REGION":    awsregion,
		"SUMOLOGIC_ACCESSID":    common.SumologicAccessID,
		"SUMOLOGIC_ACCESSKEY":   common.SumologicAccessKey,
		"SUMOLOGIC_ENVIRONMENT": common.SumologicEnvironment,
	}

	terraformOptions, resourceCount := common.ApplyTerraformWithVars(t, vars, envVars)

	return terraformOptions, resourceCount
}

func UpdateTerraform(t *testing.T, vars map[string]interface{}, options *terraform.Options) *terraform.ResourceCount {
	options.Vars = vars
	out := terraform.Apply(t, options)
	return terraform.GetResourceCount(t, out)
}

func TestWithDefaultValues(t *testing.T) {
	t.Parallel()
	aws_region := "us-east-2"

	// Create the LB before deploying the module so the "Existing" lambda auto-enables access logs at deploy time
	assertResource := common.GetAssertResource(t, map[string]string{"AWS_DEFAULT_REGION": aws_region})
	lb_id, _ := assertResource.CreateELB("TestWithDefaultValuesLB", "TestWithDefaultValuesTG")

	vars := map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"auto_enable_access_logs":   "Both",
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 21, 0, 0)
	})

	outputs := common.FetchAllOutputs(t, options)
	replacementMap := map[string]interface{}{
		"AccountId":     aws.GetAccountId(t),
		"Region":        aws_region,
		"SumoAccountId": common.SumoAccountId,
		"Deployment":    common.SumologicEnvironment,
		"OrgId":         common.SumologicOrganizationId,
		"RandomString":  outputs["random_string"].(map[string]interface{})["id"].(string),
	}
	// Assert if the outputs are actually created in AWS and Sumo Logic.
	// This also checks if your expectation are matched with the outputs, so provide an JSON with expected outputs.
	expectedOutputs := common.ReadJsonFile("TestWithDefaultValues.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, options, expectedOutputs)
	})

	// Validate that the auto-enable lambda configured access logs on the LB
	time.Sleep(2 * time.Minute)
	bucket := outputs["aws_s3_bucket"].(map[string]interface{})["s3_bucket"].(map[string]interface{})["bucket"].(string)
	assertResource.ValidateLoadBalancerAccessLogs(lb_id, bucket)

	// Upload a synthetic ELB access log directly to S3.
	// This tests the real S3 → SNS → Sumo Logic ingestion pipeline without relying on network connectivity to the ALB 
	accountId := aws.GetAccountId(t)
	now := time.Now().UTC()
	logKey := fmt.Sprintf("elasticloadbalancing/AWSLogs/%s/elasticloadbalancing/%s/%s/%s_elasticloadbalancing_%s_app.TestWithDefaultValuesLB_%sZ_10.0.0.1_test.log",
		accountId, aws_region, now.Format("2006/01/02"),
		accountId, aws_region, now.Format("20060102T1504"))
	logContent := fmt.Sprintf(
		`http %s app/TestWithDefaultValuesLB/abcdef1234567890 10.0.0.1:12345 10.0.1.1:80 0.001 0.002 0.000 200 200 0 57 "GET http://TestWithDefaultValuesLB-1076212475.us-east-2.elb.amazonaws.com:80/ HTTP/1.1" "curl/7.64.1" - - arn:aws:elasticloadbalancing:us-east-2:%s:targetgroup/TestWithDefaultValuesTG/abcdef1234567890 "Root=1-abcdef12-abcdef1234567890abcdef12" "-" "-" 0 %s "forward" "-" "-" "10.0.1.1:80" "200" "-" "-"`,
		now.Format("2006-01-02T15:04:05.000000Z"), accountId, now.Format("2006-01-02T15:04:05.000000Z"))

	fmt.Printf("Uploading synthetic ELB log to s3://%s/%s\n", bucket, logKey)
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(aws_region))
	if err != nil {
		t.Fatalf("Failed to load AWS config: %v", err)
	}
	s3Client := s3.NewFromConfig(cfg)
	_, err = s3Client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws_sdk.String(bucket),
		Key:    aws_sdk.String(logKey),
		Body:   strings.NewReader(logContent),
	})
	if err != nil {
		t.Fatalf("Failed to upload synthetic log to S3: %v", err)
	}
	fmt.Println("Synthetic log uploaded successfully.")

	// Verify the file exists in S3
	headOut, headErr := s3Client.HeadObject(context.TODO(), &s3.HeadObjectInput{
		Bucket: aws_sdk.String(bucket),
		Key:    aws_sdk.String(logKey),
	})
	if headErr != nil {
		t.Fatalf("Synthetic log file not found in S3: %v", headErr)
	}
	fmt.Printf("Confirmed file in S3: size=%d, lastModified=%s\n", *headOut.ContentLength, headOut.LastModified.String())

	// Wait for Sumo Logic to pick up the file via polling (scan_interval=5min)
	fmt.Println("Waiting 6 minutes for Sumo Logic source to scan and ingest...")
	time.Sleep(6 * time.Minute)

	// Search with retries: 10 retries x 1 min = 10 min additional wait
	sourceId := outputs["sumologic_source"].(map[string]interface{})["id"].(string)
	fmt.Printf("Searching for logs with _sourceid=%s\n", sourceId)
	assertResource.CheckLogsForPastSixtyMinutes("_sourceid="+sourceId, 10, 1*time.Minute)
}

func TestWithExistingResourcesValues(t *testing.T) {
	t.Parallel()
	BUCKET_NAME := os.Getenv("BUCKET_NAME_US_WEST_1")
	PATH_EXPRESSION := os.Getenv("PATH_EXPRESSION_US_WEST_1")
	SNS_TOPIC := os.Getenv("TOPIC_ARN_US_WEST_1")

	aws_region := "us-west-1"
	assertResource := common.GetAssertResource(t, map[string]string{"AWS_DEFAULT_REGION": aws_region})
	lb_id, dns := assertResource.CreateELB("TestWithDefaultValuesLB", "TestWithDefaultValuesTG")
	vars := map[string]interface{}{
		"create_collector":          false,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"auto_enable_access_logs":   "Existing",
		"wait_for_seconds":          1,
		"source_details": map[string]interface{}{
			"source_name":     "My ELB Source Existing Resources",
			"source_category": "Labs/test/elb",
			"description":     "This source is created.",
			"bucket_details": map[string]interface{}{
				"create_bucket":        false,
				"bucket_name":          BUCKET_NAME,
				"path_expression":      PATH_EXPRESSION,
				"force_destroy_bucket": true,
			},
			"paused":               false,
			"scan_interval":        60000,
			"cutoff_relative_time": "-1d",
			"fields": map[string]string{
				"TestCollector": "MyValue",
			},
			"sumo_account_id": "926226587429",
			"collector_id":    COLLECTOR_ID,
			"iam_details": map[string]interface{}{
				"create_iam_role": false,
				"iam_role_arn":    IAM_ROLE,
			},
			"sns_topic_details": map[string]interface{}{
				"create_sns_topic": false,
				"sns_topic_arn":    SNS_TOPIC,
			},
		},
        "aws_resource_tags": map[string]interface{}{
		    "Creator": "SumoLogic",
			"Environment": "Test",
		},
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 5, 0, 0)
	})

	outputs := common.FetchAllOutputs(t, options)
	replacementMap := map[string]interface{}{
		"AccountId":      aws.GetAccountId(t),
		"Region":         aws_region,
		"SumoAccountId":  common.SumoAccountId,
		"Deployment":     common.SumologicEnvironment,
		"OrgId":          common.SumologicOrganizationId,
		"BucketName":     BUCKET_NAME,
		"PathExpression": PATH_EXPRESSION,
		"RandomString":   outputs["random_string"].(map[string]interface{})["id"].(string),
	}
	// Assert if the outputs are actually created in AWS and Sumo Logic.
	// This also checks if your expectation are matched with the outputs, so provide an JSON with expected outputs.
	expectedOutputs := common.ReadJsonFile("TestWithExistingResourcesValues.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, options, expectedOutputs)
	})

	// Before checking logs, create a load balancer, check if access logs has been enabled and then hit it to generate logs
	http.Get(fmt.Sprintf("http://%s", *dns))

	// Assert if the logs are sent to Sumo Logic.
	assertResource.ValidateLoadBalancerAccessLogs(lb_id, BUCKET_NAME)
	assertResource.CheckLogsForPastSixtyMinutes("_sourceid="+outputs["sumologic_source"].(map[string]interface{})["id"].(string), 5, 2*time.Minute)
}

func TestWithExistingCollectorIAMNewSNSResources(t *testing.T) {
	t.Parallel()
	BUCKET_NAME := os.Getenv("BUCKET_NAME_AP_SOUTH_1")
	PATH_EXPRESSION := os.Getenv("PATH_EXPRESSION_AP_SOUTH_1")

	aws_region := "ap-south-1"
	assertResource := common.GetAssertResource(t, map[string]string{"AWS_DEFAULT_REGION": aws_region})
	lb_id, dns := assertResource.CreateELB("TestWithDefaultValuesLB", "TestWithDefaultValuesTG")
	vars := map[string]interface{}{
		"create_collector":          false,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"auto_enable_access_logs":   "Existing",
		"wait_for_seconds":          1,
		"source_details": map[string]interface{}{
			"source_name":     "My ELB Source Exixting IAM",
			"source_category": "Labs/test/elb",
			"description":     "This source is created.",
			"bucket_details": map[string]interface{}{
				"create_bucket":        false,
				"bucket_name":          BUCKET_NAME,
				"path_expression":      PATH_EXPRESSION,
				"force_destroy_bucket": true,
			},
			"paused":               false,
			"scan_interval":        60000,
			"cutoff_relative_time": "-1d",
			"fields": map[string]string{
				"TestCollector": "MyValue",
			},
			"sumo_account_id": "926226587429",
			"collector_id":    COLLECTOR_ID,
			"iam_details": map[string]interface{}{
				"create_iam_role": false,
				"iam_role_arn":    IAM_ROLE,
			},
			"sns_topic_details": map[string]interface{}{
				"create_sns_topic": true,
				"sns_topic_arn":    nil,
			},
		},
        "aws_resource_tags": map[string]interface{}{
		    "Creator": "SumoLogic",
			"Environment": "Test",
		},
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 6, 0, 0)
	})

	outputs := common.FetchAllOutputs(t, options)
	replacementMap := map[string]interface{}{
		"AccountId":      aws.GetAccountId(t),
		"Region":         aws_region,
		"SumoAccountId":  common.SumoAccountId,
		"Deployment":     common.SumologicEnvironment,
		"OrgId":          common.SumologicOrganizationId,
		"BucketName":     BUCKET_NAME,
		"PathExpression": PATH_EXPRESSION,
		"RandomString":   outputs["random_string"].(map[string]interface{})["id"].(string),
	}
	// Assert if the outputs are actually created in AWS and Sumo Logic.
	// This also checks if your expectation are matched with the outputs, so provide an JSON with expected outputs.
	expectedOutputs := common.ReadJsonFile("TestWithExistingCollectorIAMNewSNSResources.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, options, expectedOutputs)
	})

	// Before checking logs, create a load balancer, check if access logs has been enabled and then hit it to generate logs
	http.Get(fmt.Sprintf("http://%s", *dns))

	// Assert if the logs are sent to Sumo Logic.
	assertResource.ValidateLoadBalancerAccessLogs(lb_id, BUCKET_NAME)
	assertResource.CheckLogsForPastSixtyMinutes("_sourceid="+outputs["sumologic_source"].(map[string]interface{})["id"].(string), 5, 2*time.Minute)
}

func TestUpdates(t *testing.T) {
	t.Parallel()
	aws_region := "us-east-1"
	vars := map[string]interface{}{
		"create_collector": true,
		"collector_details": map[string]interface{}{
			"collector_name": "Test Updates",
			"description":    "This collector is created for testing elb terraform module.",
			"fields": map[string]interface{}{
				"MyCollector": "TestTerraform",
			},
		},
		"sumologic_organization_id": common.SumologicOrganizationId,
		"auto_enable_access_logs":   "Existing",
	    "aws_resource_tags": map[string]interface{}{
		    "Creator": "SumoLogic",
			"Environment": "Test",
		},
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 17, 0, 0)
	})

	vars = map[string]interface{}{
		"create_collector": true,
		"collector_details": map[string]interface{}{
			"collector_name": "Test Updates Again",
			"description":    "This collector is created for testing elb terraform module.",
			"fields": map[string]interface{}{
				"MyCollector": "TestTerraform",
			},
		},
		"sumologic_organization_id": common.SumologicOrganizationId,
		"auto_enable_access_logs":   "None",
	}

	count = UpdateTerraform(t, vars, options)

	test_structure.RunTestStage(t, "UpdateFirst", func() {
		common.AssertResourceCounts(t, count, 0, 4, 1)
	})
}
