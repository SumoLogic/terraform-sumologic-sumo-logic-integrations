package cloudtrail

import (
	"os"
	"testing"
	"time"

	"github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/terratest/common"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

var replacementMap map[string]interface{}
var terraformOptions *terraform.Options
var resourceCount *terraform.ResourceCount

// Env Variables
var BUCKET_NAME = os.Getenv("BUCKET_NAME")
var PATH_EXPRESSION = os.Getenv("PATH_EXPRESSION")

func SetUpTest(t *testing.T, vars map[string]interface{}, awsregion string) {
	AwsAccountId := aws.GetAccountId(t)

	envVars := map[string]string{
		"AWS_DEFAULT_REGION":    awsregion,
		"SUMOLOGIC_ACCESSID":    common.SumologicAccessID,
		"SUMOLOGIC_ACCESSKEY":   common.SumologicAccessKey,
		"SUMOLOGIC_ENVIRONMENT": common.SumologicEnvironment,
	}

	replacementMap = map[string]interface{}{
		"AccountId":      AwsAccountId,
		"Region":         awsregion,
		"SumoAccountId":  common.SumoAccountId,
		"Deployment":     common.SumologicEnvironment,
		"OrgId":          common.SumologicOrganizationId,
		"BucketName":     BUCKET_NAME,
		"PathExpression": PATH_EXPRESSION,
	}

	terraformOptions, resourceCount = common.ApplyTerraformWithVars(t, vars, envVars)
	t.Cleanup(func() {
		common.CleanupTerraform(t, terraformOptions)
	})
}

func UpdateTerraform(t *testing.T, vars map[string]interface{}) *terraform.ResourceCount {
	terraformOptions.Vars = vars
	out := terraform.Apply(t, terraformOptions)
	return terraform.GetResourceCount(t, out)
}

// Test Cases

// 4. With Existing Bucket, Existing Trail, Existing Collector, Old SNS Topic, Old IAM Role (All Existing)
// 5. With New Bucket, Existing Trail (we will create a new trail), new Collector, New SNS Topic, New IAM Role
// 6. Check for updates by changing variables. Assert only resources - Implemented

// 1. With Default Values - Implemented
func TestWithDefaultValues(t *testing.T) {
	vars := map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_trail":              true,
	}

	SetUpTest(t, vars, "us-east-2")

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, resourceCount, 10, 0, 0)
	})

	// Assert if the outputs are actually created in AWS and Sumo Logic.
	// This also checks if your expectation are matched with the outputs, so provide an JSON with expected outputs.
	expectedOutputs := common.ReadJsonFile("defaultoutput.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, terraformOptions, expectedOutputs)
	})

	// Assert if the logs are sent to Sumo Logic.
	outputs := common.FetchAllOutputs(t, terraformOptions)
	common.GetAssertResource(terraformOptions).CheckLogsForPastSixtyMinutes(t, "_sourceid="+outputs["sumologic_source"].(map[string]interface{})["id"].(string), 5, 2*time.Minute)
}

// 2. With Existing Bucket, Existing Trail, new Collector, New SNS Topic, New IAM Role
func TestWithExistingBucketTrailNewCollectorSNSIAM(t *testing.T) {
	vars := map[string]interface{}{
		"create_collector": true,
		"collector_details": map[string]interface{}{
			"collector_name": "Test With Existing Bucket Trail New Collector SNS IAM",
			"description":    "This collector is created for testing CloudTrail terraform module.",
			"fields": map[string]interface{}{
				"MyCollector": "TestTerraform",
			},
		},
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_trail":              false,
		"source_details": map[string]interface{}{
			"source_name":     "My Test Source",
			"source_category": "Labs/test/cloudtrail",
			"description":     "This source is ceated a.",
			"bucket_details": map[string]interface{}{
				"create_bucket":   false,
				"bucket_name":     BUCKET_NAME,
				"path_expression": PATH_EXPRESSION,
				// This does not have any impact as terraform does not manage existing bucket.
				"force_destroy_bucket": true,
			},
			"paused":               false,
			"scan_interval":        60000,
			"cutoff_relative_time": "-1d",
			"fields": map[string]interface{}{
				"MySource": "TestSourceTerraform",
			},
			"sumo_account_id": "926226587429",
			"collector_id":    "",
			"iam_role_arn":    "",
			"sns_topic_arn":   "",
		},
	}

	SetUpTest(t, vars, "us-east-1")

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, resourceCount, 7, 0, 0)
	})

	// Assert if the outputs are actually created in AWS and Sumo Logic.
	// This also checks if your expectation are matched with the outputs, so provide an JSON with expected outputs.
	expectedOutputs := common.ReadJsonFile("TestWithExistingBucketTrailNewCollectorSNSIAM.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, terraformOptions, expectedOutputs)
	})

	// Assert if the logs are sent to Sumo Logic.
	outputs := common.FetchAllOutputs(t, terraformOptions)
	common.GetAssertResource(terraformOptions).CheckLogsForPastSixtyMinutes(t, "_sourceid="+outputs["sumologic_source"].(map[string]interface{})["id"].(string), 5, 2*time.Minute)
}
