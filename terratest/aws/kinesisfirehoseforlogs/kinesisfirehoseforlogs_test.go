package kinesisfirehoseforlogs

import (
	"os"
	"testing"
	"time"

	"github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/terratest/common"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

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
	aws_region := "us-east-1"
	vars := map[string]interface{}{
		"create_collector":              true,
		"sumologic_organization_id":     common.SumologicOrganizationId,
		"auto_enable_logs_subscription": "Both",
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 19, 0, 0)
	})

	assertResource := common.GetAssertResource(t, options.EnvVars)
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
		common.AssertOutputs(t, options, expectedOutputs)
	})

	// Assert if the logs are sent to Sumo Logic.
	assertResource.CheckLogsForPastSixtyMinutes("_sourceid="+outputs["sumologic_source"].(map[string]interface{})["id"].(string), 5, 2*time.Minute)
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
		"create_collector":          false,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"source_details": map[string]interface{}{
			"source_name":     "Test Source For Logs One",
			"source_category": "My/Test/cvategory",
			"collector_id":    COLLECTOR_ID,
			"description":     "This is jsyd",
			"fields": map[string]string{
				"TestCollector": "MyValue",
			},
		},
		"auto_enable_logs_subscription": "New",
		"auto_enable_logs_subscription_options": map[string]interface{}{
			"filter": "aws",
		},
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 16, 0, 0)
	})

	assertResource := common.GetAssertResource(t, options.EnvVars)
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
	}
	// Assert if the outputs are actually created in AWS and Sumo Logic.
	// This also checks if your expectation are matched with the outputs, so provide an JSON with expected outputs.
	expectedOutputs := common.ReadJsonFile("TestWithExistingValues.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, options, expectedOutputs)
	})

	// Assert if the logs are sent to Sumo Logic.
	assertResource.CheckLogsForPastSixtyMinutes("_sourceid="+outputs["sumologic_source"].(map[string]interface{})["id"].(string), 5, 2*time.Minute)
}

func TestUpdates(t *testing.T) {
	t.Parallel()
	aws_region := "us-east-2"
	vars := map[string]interface{}{
		"create_collector": true,
		"collector_details": map[string]interface{}{
			"collector_name": "Test Updates",
			"description":    "This collector is created for testing elb terraform module.",
			"fields": map[string]interface{}{
				"MyCollector": "TestTerraform",
			},
		},
		"sumologic_organization_id":     common.SumologicOrganizationId,
		"auto_enable_logs_subscription": "Existing",
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 19, 0, 0)
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
		"sumologic_organization_id":     common.SumologicOrganizationId,
		"auto_enable_logs_subscription": "None",
	}

	count = UpdateTerraform(t, vars, options)

	test_structure.RunTestStage(t, "UpdateFirst", func() {
		common.AssertResourceCounts(t, count, 0, 1, 1)
	})

	vars = map[string]interface{}{
		"create_collector":              false,
		"sumologic_organization_id":     common.SumologicOrganizationId,
		"auto_enable_logs_subscription": "None",
		"source_details": map[string]interface{}{
			"source_name":     "Test Source For Logs Two",
			"source_category": "My/Test/cvategory",
			"collector_id":    COLLECTOR_ID,
			"description":     "This is jsyd",
			"fields": map[string]string{
				"TestCollector": "MyValue",
			},
		},
	}

	count = UpdateTerraform(t, vars, options)

	test_structure.RunTestStage(t, "UpdateFirst", func() {
		common.AssertResourceCounts(t, count, 1, 1, 2)
	})
}
