package kinesisfirehoseformetrics

import (
	"fmt"
	"os"
	"strconv"
	"testing"
	"time"

	"github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/terratest/common"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

var COLLECTOR_ID = os.Getenv("COLLECTOR_ID")
var IAM_ROLE = os.Getenv("IAM_ROLE")
var LOOK_UP_MAP = map[string]string{"source_aws_iam_role": "aws_iam_role"}

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
	aws_region := "us-east-1"
	vars := map[string]interface{}{
		"create_bucket":             true,
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
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
		"URL":           outputs["sumologic_source"].(map[string]interface{})["url"].(string),
	}
	// Assert if the outputs are actually created in AWS and Sumo Logic.
	// This also checks if your expectation are matched with the outputs, so provide an JSON with expected outputs.
	expectedOutputs := common.ReadJsonFile("TestWithDefaultValues.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputsWithLookup(t, options, expectedOutputs, LOOK_UP_MAP)
	})

	// Assert if the logs are sent to Sumo Logic.
	sourceId, _ := strconv.ParseInt(outputs["sumologic_source"].(map[string]interface{})["id"].(string), 10, 64)
	common.GetAssertResource(t, options.EnvVars).CheckMetricsForPastSixtyMinutes(fmt.Sprintf("_sourceid=%v | count by region", fmt.Sprintf("%016x", sourceId)), 5, 2*time.Minute)
}

func TestWithExistingValues(t *testing.T) {
	t.Parallel()
	aws_region := "us-west-1"
	BUCKET_NAME := os.Getenv("BUCKET_NAME_US_WEST_1")
	vars := map[string]interface{}{
		"create_bucket": false,
		"bucket_details": map[string]interface{}{
			"bucket_name":          BUCKET_NAME,
			"force_destroy_bucket": true,
		},
		"create_collector": false,
		"source_details": map[string]interface{}{
			"source_name":     "Test Source For Metrics One",
			"source_category": "My/Test/cvategory",
			"collector_id":    COLLECTOR_ID,
			"description":     "This is jsyd",
			"fields": map[string]string{
				"TestCollector": "MyValue",
			},
			"sumo_account_id":     "926226587429",
			"limit_to_namespaces": []string{"AWS/SNS", "AWS/SQS", "AWS/Events", "AWS/Lambda", "AWS/Logs", "AWS/S3", "AWS/Firehose"},
			"iam_details": map[string]interface{}{
				"create_iam_role": false,
				"iam_role_arn":    IAM_ROLE,
			},
		},
		"sumologic_organization_id": common.SumologicOrganizationId,
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 16, 0, 0)
	})

	outputs := common.FetchAllOutputs(t, options)
	replacementMap := map[string]interface{}{
		"AccountId":     aws.GetAccountId(t),
		"Region":        aws_region,
		"SumoAccountId": common.SumoAccountId,
		"Deployment":    common.SumologicEnvironment,
		"OrgId":         common.SumologicOrganizationId,
		"RandomString":  outputs["random_string"].(map[string]interface{})["id"].(string),
		"URL":           outputs["sumologic_source"].(map[string]interface{})["url"].(string),
		"BucketName":    BUCKET_NAME,
		"ROLE_ARN":      IAM_ROLE,
	}
	// Assert if the outputs are actually created in AWS and Sumo Logic.
	// This also checks if your expectation are matched with the outputs, so provide an JSON with expected outputs.
	expectedOutputs := common.ReadJsonFile("TestWithExistingValues.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, options, expectedOutputs)
	})

	// Assert if the logs are sent to Sumo Logic.
	sourceId, _ := strconv.ParseInt(outputs["sumologic_source"].(map[string]interface{})["id"].(string), 10, 64)
	common.GetAssertResource(t, options.EnvVars).CheckMetricsForPastSixtyMinutes(fmt.Sprintf("_sourceid=%v | count by region", fmt.Sprintf("%016x", sourceId)), 5, 3*time.Minute)
}

func TestUpdates(t *testing.T) {
	t.Parallel()
	aws_region := "ap-south-1"
	BUCKET_NAME := os.Getenv("BUCKET_NAME_AP_SOUTH_1")
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
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 21, 0, 0)
	})

	vars = map[string]interface{}{
		"create_collector": true,
		"create_bucket":    false,
		"bucket_details": map[string]interface{}{
			"bucket_name":          BUCKET_NAME,
			"force_destroy_bucket": true,
		},
		"collector_details": map[string]interface{}{
			"collector_name": "Test Updates",
			"description":    "This collector is created for testing elb terraform module.",
			"fields": map[string]interface{}{
				"MyCollector": "TestTerraform",
			},
		},
		"sumologic_organization_id": common.SumologicOrganizationId,
	}

	count = UpdateTerraform(t, vars, options)

	test_structure.RunTestStage(t, "UpdateFirst", func() {
		common.AssertResourceCounts(t, count, 0, 2, 2)
	})

	vars = map[string]interface{}{
		"create_collector": false,
		"create_bucket":    false,
		"bucket_details": map[string]interface{}{
			"bucket_name":          BUCKET_NAME,
			"force_destroy_bucket": true,
		},
		"source_details": map[string]interface{}{
			"source_name":     "Test Source For Metrics Two",
			"source_category": "My/Test/cvategory",
			"collector_id":    COLLECTOR_ID,
			"description":     "This is jsyd",
			"fields": map[string]string{
				"TestCollector": "MyValue",
			},
			"sumo_account_id":     "926226587429",
			"limit_to_namespaces": []string{"AWS/SNS", "AWS/SQS", "AWS/Events"},
			"iam_details": map[string]interface{}{
				"create_iam_role": true,
				"iam_role_arn":    nil,
			},
		},
		"sumologic_organization_id": common.SumologicOrganizationId,
	}

	count = UpdateTerraform(t, vars, options)

	test_structure.RunTestStage(t, "UpdateFirst", func() {
		common.AssertResourceCounts(t, count, 1, 2, 2)
	})
}
