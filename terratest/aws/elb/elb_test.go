package elb

import (
	"fmt"
	"net/http"
	"os"
	"testing"
	"time"

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
	vars := map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"auto_enable_access_logs":   "Both",
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 13, 0, 0)
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

	// Before checking logs, create a load balancer, check if access logs has been enabled and then hit it to generate logs
	assertResource := common.GetAssertResource(t, options.EnvVars)
	lb_id, dns := assertResource.CreateELB("TestWithDefaultValuesLB", "TestWithDefaultValuesTG")
	time.Sleep(2 * time.Minute)
	http.Get(fmt.Sprintf("http://%s", *dns))

	// Assert if the logs are sent to Sumo Logic.
	assertResource.CheckLogsForPastSixtyMinutes("_sourceid="+outputs["sumologic_source"].(map[string]interface{})["id"].(string), 5, 2*time.Minute)
	assertResource.ValidateLoadBalancerAccessLogs(lb_id, outputs["aws_s3_bucket"].(map[string]interface{})["s3_bucket"].(map[string]interface{})["bucket"].(string))
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
		common.AssertResourceCounts(t, count, 13, 0, 0)
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
