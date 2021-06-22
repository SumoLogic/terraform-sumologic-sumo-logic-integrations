package cloudtrail

import (
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/terratest/common"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

// Env Variables
var BUCKET_NAME = os.Getenv("BUCKET_NAME")
var IAM_ROLE = os.Getenv("IAM_ROLE")
var SNS_TOPIC = os.Getenv("TOPIC_ARN")
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

// 1. With Default Values - Implemented
func TestWithDefaultValues(t *testing.T) {
	t.Parallel()
	aws_region := "us-east-2"
	vars := map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_trail":              true,
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 11, 0, 0)
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

	// Assert if the logs are sent to Sumo Logic.
	common.GetAssertResource(t, options.EnvVars).CheckLogsForPastSixtyMinutes("_sourceid="+outputs["sumologic_source"].(map[string]interface{})["id"].(string), 5, 2*time.Minute)
}

// 2. With Existing Bucket, Existing Trail, new Collector, New SNS Topic, New IAM Role
func TestWithExistingBucketTrailNewCollectorSNSIAM(t *testing.T) {
	t.Parallel()
	aws_region := "us-west-1"
	PATH_EXPRESSION := fmt.Sprintf("AWSLogs/%s/CloudTrail/%s/*", aws.GetAccountId(t), aws_region)

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

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 8, 0, 0)
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
	expectedOutputs := common.ReadJsonFile("TestWithExistingBucketTrailNewCollectorSNSIAM.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, options, expectedOutputs)
	})

	// Assert if the logs are sent to Sumo Logic.
	common.GetAssertResource(t, options.EnvVars).CheckLogsForPastSixtyMinutes("_sourceid="+outputs["sumologic_source"].(map[string]interface{})["id"].(string), 5, 2*time.Minute)
}

// 3. With Existing Bucket, Existing Trail, Existing Collector, Old SNS Topic, Old IAM Role (All Existing)
func TestWithExistingBucketTrailCollectorSNSIAM(t *testing.T) {
	t.Parallel()
	aws_region := "us-east-1"
	PATH_EXPRESSION := fmt.Sprintf("AWSLogs/%s/CloudTrail/%s/*", aws.GetAccountId(t), aws_region)
	vars := map[string]interface{}{
		"create_collector":          false,
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
			"collector_id":    COLLECTOR_ID,
			"iam_role_arn":    IAM_ROLE,
			"sns_topic_arn":   SNS_TOPIC,
		},
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 4, 0, 0)
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
		"SNS_TOPIC_ARN":  SNS_TOPIC,
		"RandomString":   outputs["random_string"].(map[string]interface{})["id"].(string),
	}
	// Assert if the outputs are actually created in AWS and Sumo Logic.
	// This also checks if your expectation are matched with the outputs, so provide an JSON with expected outputs.
	expectedOutputs := common.ReadJsonFile("TestWithExistingBucketTrailCollectorSNSIAM.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, options, expectedOutputs)
	})

	// Assert if the logs are sent to Sumo Logic.
	common.GetAssertResource(t, options.EnvVars).CheckLogsForPastSixtyMinutes("_sourceid="+outputs["sumologic_source"].(map[string]interface{})["id"].(string), 5, 2*time.Minute)
}

// 4. With New Bucket, Existing Trail (we will create a new trail), new Collector, New SNS Topic, New IAM Role
func TestWithExistingTrailNewBucketCollectorSNSIAM(t *testing.T) {
	t.Parallel()
	aws_region := "us-west-2"
	PATH_EXPRESSION := fmt.Sprintf("AWSLogs/%s/CloudTrail/%s/*", aws.GetAccountId(t), aws_region)
	vars := map[string]interface{}{
		"create_collector": true,
		"collector_details": map[string]interface{}{
			"collector_name": "Test With Existing Trail New Bucket Collector SNS IAM",
			"description":    "thsisia",
			"fields":         map[string]interface{}{},
		},
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_trail":              false,
		"source_details": map[string]interface{}{
			"source_name":     "My Test Source",
			"source_category": "Labs/test/cloudtrail",
			"description":     "This source is ceated a.",
			"bucket_details": map[string]interface{}{
				"create_bucket":   true,
				"bucket_name":     "my-test-tf-mod-us-west-2",
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

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 11, 0, 0)
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
	expectedOutputs := common.ReadJsonFile("TestWithExistingTrailNewBucketCollectorSNSIAM.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, options, expectedOutputs)
	})

	// Assert if the logs are sent to Sumo Logic.
	common.GetAssertResource(t, options.EnvVars).CheckLogsForPastSixtyMinutes("_sourceid="+outputs["sumologic_source"].(map[string]interface{})["id"].(string), 5, 2*time.Minute)
}

// 5. Check for updates by changing variables. Assert only resources - Implemented
func TestUpdates(t *testing.T) {
	t.Parallel()
	aws_region := "ap-south-1"
	var PATH_EXPRESSION = os.Getenv("PATH_EXPRESSION")
	vars := map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_trail":              true,
		"collector_details": map[string]interface{}{
			"collector_name": "Test Updates Cloudtrail Module",
			"description":    "thsisia",
			"fields":         map[string]interface{}{},
		},
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 11, 0, 0)
	})

	// Updating the Collector Name, description and fields only
	vars = map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_trail":              true,
		"collector_details": map[string]interface{}{
			"collector_name": "Test Updated Cloudtrail Module One",
			"description":    "This is a new description.",
			"fields": map[string]interface{}{
				"TestCollector": "MyValue",
			},
		},
	}

	count = UpdateTerraform(t, vars, options)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "UpdateFirst", func() {
		common.AssertResourceCounts(t, count, 0, 1, 0)
	})

	// use existing cloudtrail and bucket with existing IAM iam_role_arn
	vars = map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_trail":              false,
		"collector_details": map[string]interface{}{
			"collector_name": "Test Updated Cloudtrail Module One",
			"description":    "This is a new description.",
			"fields": map[string]interface{}{
				"TestCollector": "MyValue",
			},
		},
		"source_details": map[string]interface{}{
			"source_name":     "My Test Source Another",
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
			"fields":               map[string]interface{}{},
			"sumo_account_id":      "926226587429",
			"collector_id":         "",
			"iam_role_arn":         IAM_ROLE,
			"sns_topic_arn":        "",
		},
	}

	count = UpdateTerraform(t, vars, options)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "UpdateFirst", func() {
		common.AssertResourceCounts(t, count, 0, 2, 5)
	})

	// update fields to source
	vars = map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_trail":              false,
		"collector_details": map[string]interface{}{
			"collector_name": "Test Updated Cloudtrail Module One",
			"description":    "This is a new description.",
			"fields": map[string]interface{}{
				"TestCollector": "MyValue",
			},
		},
		"source_details": map[string]interface{}{
			"source_name":     "My Test Source Another",
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
				"TestCollector": "MyValue",
			},
			"sumo_account_id": "926226587429",
			"collector_id":    "",
			"iam_role_arn":    IAM_ROLE,
			"sns_topic_arn":   "",
		},
	}

	count = UpdateTerraform(t, vars, options)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "UpdateFirst", func() {
		common.AssertResourceCounts(t, count, 0, 1, 0)
	})
}
