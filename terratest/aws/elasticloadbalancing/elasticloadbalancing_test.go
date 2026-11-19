package elasticloadbalancing

import (
	"os"
	"testing"

	"github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/terratest/common"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

var IAM_ROLE = os.Getenv("IAM_ROLE")
var COLLECTOR_ID = os.Getenv("COLLECTOR_ID")

// classicLBAutoEnableOptions mirrors how the AWSO 3.0.0 collections module configures the classic LB
// auto enable. TestWithDefaultValues deliberately does not use it, so the module defaults stay covered.
func classicLBAutoEnableOptions() map[string]interface{} {
	return map[string]interface{}{
		"bucket_prefix":          "elasticloadbalancing",
		"auto_enable_logging":    "ELB",
		"filter":                 "'apiVersion': '2012-06-01'",
		"remove_on_delete_stack": true,
	}
}

func SetUpTest(t *testing.T, vars map[string]interface{}, awsregion string) (*terraform.Options, *terraform.ResourceCount) {
	envVars := map[string]string{
		"AWS_DEFAULT_REGION":    awsregion,
		"SUMOLOGIC_ACCESSID":    common.SumologicAccessID,
		"SUMOLOGIC_ACCESSKEY":   common.SumologicAccessKey,
		"SUMOLOGIC_ENVIRONMENT": common.SumologicEnvironment,
	}

	return common.ApplyTerraformWithVars(t, vars, envVars)
}

func UpdateTerraform(t *testing.T, vars map[string]interface{}, options *terraform.Options) *terraform.ResourceCount {
	options.Vars = vars
	out := terraform.Apply(t, options)
	return terraform.GetResourceCount(t, out)
}

func replacements(t *testing.T, region string, outputs map[string]interface{}, extra map[string]interface{}) map[string]interface{} {
	m := map[string]interface{}{
		"AccountId":     aws.GetAccountId(t),
		"Region":        region,
		"SumoAccountId": common.SumoAccountId,
		"Deployment":    common.SumologicEnvironment,
		"OrgId":         common.SumologicOrganizationId,
		"RandomString":  outputs["random_string"].(map[string]interface{})["id"].(string),
	}
	for k, v := range extra {
		m[k] = v
	}
	return m
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

	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 21, 0, 0)
	})

	outputs := common.FetchAllOutputs(t, options)
	expectedOutputs := common.ReadJsonFile("TestWithDefaultValues.json", replacements(t, aws_region, outputs, nil))
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, options, expectedOutputs)
	})
}

func TestWithExistingResourcesValues(t *testing.T) {
	t.Parallel()
	BUCKET_NAME := os.Getenv("BUCKET_NAME_US_WEST_1")
	PATH_EXPRESSION := os.Getenv("PATH_EXPRESSION_US_WEST_1")
	SNS_TOPIC := os.Getenv("TOPIC_ARN_US_WEST_1")

	aws_region := "us-west-1"
	vars := map[string]interface{}{
		"create_collector":                false,
		"sumologic_organization_id":       common.SumologicOrganizationId,
		"auto_enable_access_logs":         "Existing",
		"auto_enable_access_logs_options": classicLBAutoEnableOptions(),
		"wait_for_seconds":                1,
		"source_details": map[string]interface{}{
			"source_name":     "My Classic ELB Source Existing Resources",
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
			"sumo_account_id": common.SumoAccountId,
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
			"Creator":     "SumoLogic",
			"Environment": "Test",
		},
	}

	options, count := SetUpTest(t, vars, aws_region)

	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 10, 0, 0)
	})

	outputs := common.FetchAllOutputs(t, options)
	expectedOutputs := common.ReadJsonFile("TestWithExistingResourcesValues.json", replacements(t, aws_region, outputs, map[string]interface{}{
		"BucketName":     BUCKET_NAME,
		"PathExpression": PATH_EXPRESSION,
		"SnsTopicArn":    SNS_TOPIC,
	}))
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, options, expectedOutputs)
	})
}

// TestAWSOCallPattern mirrors how the terraform-sumologic-aws-observability (AWSO 3.0.0) collections
// module calls this module: existing collector, bucket, IAM role and SNS topic, with the SNS
// subscription, bucket policy and bucket notification delegated to the AWSO Lambda helper.
func TestAWSOCallPattern(t *testing.T) {
	t.Parallel()
	BUCKET_NAME := os.Getenv("BUCKET_NAME_US_WEST_1")
	PATH_EXPRESSION := os.Getenv("PATH_EXPRESSION_US_WEST_1")
	SNS_TOPIC := os.Getenv("TOPIC_ARN_US_WEST_1")

	aws_region := "us-west-1"
	vars := map[string]interface{}{
		"create_collector":                    false,
		"sumologic_organization_id":           common.SumologicOrganizationId,
		"auto_enable_access_logs":             "Both",
		"auto_enable_access_logs_options":     classicLBAutoEnableOptions(),
		"wait_for_seconds":                    1,
		"create_sns_subscription":             false,
		"create_existing_bucket_policy":       false,
		"create_existing_bucket_notification": false,
		"aws_cli_profile":                     os.Getenv("AWS_PROFILE"),
		"source_details": map[string]interface{}{
			"source_name":     "My Classic ELB Source AWSO Call Pattern",
			"source_category": "Labs/test/elb",
			"description":     "This source is created.",
			"bucket_details": map[string]interface{}{
				"create_bucket":        false,
				"bucket_name":          BUCKET_NAME,
				"path_expression":      PATH_EXPRESSION,
				"force_destroy_bucket": false,
			},
			"paused":               false,
			"scan_interval":        60000,
			"cutoff_relative_time": "-1d",
			"fields": map[string]string{
				"TestCollector": "MyValue",
			},
			"sumo_account_id": common.SumoAccountId,
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
			"Creator":     "SumoLogic",
			"Environment": "Test",
		},
	}

	options, count := SetUpTest(t, vars, aws_region)

	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 12, 0, 0)
	})

	outputs := common.FetchAllOutputs(t, options)
	test_structure.RunTestStage(t, "AssertDelegatedResourcesNotCreated", func() {
		for _, key := range []string{"aws_sns_subscription", "aws_s3_bucket_notification", "aws_sns_topic", "aws_s3_bucket", "aws_iam_role", "sumologic_collector"} {
			assert.Empty(t, outputs[key], "Output %s must be empty when the resource is managed outside this module.", key)
		}
		assert.Equal(t, aws_region, outputs["elasticloadbalancing_current_region"])
		assert.NotEmpty(t, outputs["sumologic_source"].(map[string]interface{})["id"])
	})
}

// TestAutoEnableOptionsValidation checks that the module rejects an unsupported auto_enable_logging value.
func TestAutoEnableOptionsValidation(t *testing.T) {
	t.Parallel()
	opts := classicLBAutoEnableOptions()
	opts["auto_enable_logging"] = "NLB"
	envVars := map[string]string{
		"AWS_DEFAULT_REGION":    "us-east-1",
		"SUMOLOGIC_ACCESSID":    common.SumologicAccessID,
		"SUMOLOGIC_ACCESSKEY":   common.SumologicAccessKey,
		"SUMOLOGIC_ENVIRONMENT": common.SumologicEnvironment,
	}
	dir := test_structure.CopyTerraformFolderToTemp(t, "../../../aws", "elasticloadbalancing")
	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: dir,
		EnvVars:      envVars,
		Vars: map[string]interface{}{
			"create_collector":                true,
			"sumologic_organization_id":       "00000000000000",
			"auto_enable_access_logs_options": opts,
		},
	})
	terraform.Init(t, options)
	_, err := terraform.PlanE(t, options)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "ALB or ELB")
}
