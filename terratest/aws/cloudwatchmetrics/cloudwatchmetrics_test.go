package cloudwatchmetrics

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
		"source_details": map[string]interface{}{
			"source_name":          "CloudWatch Metrics Source",
			"source_category":      "Labs/aws/cloudwatch/metrics",
			"description":          "This source is created using Sumo Logic terraform AWS CloudWatch Metrics module to collect AWS Cloudwatch metrics.",
			"limit_to_regions":     []string{"us-east-1"},
			"limit_to_namespaces":  []string{},
			"paused":               false,
			"scan_interval":        60000,
			"cutoff_relative_time": "-1d",
			"fields": map[string]interface{}{
				"MySource": "TestSourceTerraform",
			},
			"sumo_account_id": "926226587429",
			"collector_id":    "",
			"iam_details": map[string]interface{}{
				"create_iam_role": true,
				"iam_role_arn":    nil,
			},
		},
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 6, 0, 0)
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
	sourceId, _ := strconv.ParseInt(outputs["sumologic_source"].(map[string]interface{})["id"].(string), 10, 64)
	common.GetAssertResource(t, options.EnvVars).CheckMetricsForPastSixtyMinutes(fmt.Sprintf("_sourceid=%v | count by region", fmt.Sprintf("%016x", sourceId)),
		5, 2*time.Minute)
}

func TestWithExistingValues(t *testing.T) {
	t.Parallel()
	aws_region := "us-east-1"
	replacementMap := map[string]interface{}{
		"AccountId":     aws.GetAccountId(t),
		"Region":        aws_region,
		"SumoAccountId": common.SumoAccountId,
		"Deployment":    common.SumologicEnvironment,
		"OrgId":         common.SumologicOrganizationId,
	}
	vars := map[string]interface{}{
		"create_collector":          false,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"source_details": map[string]interface{}{
			"source_name":          "CloudWatch Metrics Source",
			"source_category":      "Labs/aws/cloudwatch/metrics",
			"description":          "This source is created using Sumo Logic terraform AWS CloudWatch Metrics module to collect AWS Cloudwatch metrics.",
			"limit_to_regions":     []string{"ap-south-1", "us-east-1"},
			"limit_to_namespaces":  []string{},
			"paused":               false,
			"scan_interval":        60000,
			"cutoff_relative_time": "-1d",
			"fields": map[string]interface{}{
				"MySource": "TestSourceTerraform",
			},
			"sumo_account_id": "926226587429",
			"collector_id":    COLLECTOR_ID,
			"iam_details": map[string]interface{}{
				"create_iam_role": false,
				"iam_role_arn":    IAM_ROLE,
			},
		},
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 3, 0, 0)
	})

	// Assert if the outputs are actually created in AWS and Sumo Logic.
	// This also checks if your expectation are matched with the outputs, so provide an JSON with expected outputs.
	expectedOutputs := common.ReadJsonFile("TestWithExistingValues.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, options, expectedOutputs)
	})

	// Assert if the logs are sent to Sumo Logic.
	outputs := common.FetchAllOutputs(t, options)
	sourceId, _ := strconv.ParseInt(outputs["sumologic_source"].(map[string]interface{})["id"].(string), 10, 64)
	common.GetAssertResource(t, options.EnvVars).CheckMetricsForPastSixtyMinutes(fmt.Sprintf("_sourceid=%v | count by region", fmt.Sprintf("%016x", sourceId)), 5, 2*time.Minute)
}

func TestUpdates(t *testing.T) {
	t.Parallel()
	aws_region := "us-west-1"

	vars := map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"collector_details": map[string]interface{}{
			"collector_name": "Test Updates Frst",
			"description":    "This collector is created for testing CloudTrail terraform module.",
			"fields": map[string]interface{}{
				"MyCollector": "TestTerraform",
			},
		},
		"source_details": map[string]interface{}{
			"source_name":          "CloudWatch Metrics Source",
			"source_category":      "Labs/aws/cloudwatch/metrics",
			"description":          "This source is created using Sumo Logic terraform AWS CloudWatch Metrics module to collect AWS Cloudwatch metrics.",
			"limit_to_regions":     []string{"us-east-1"},
			"limit_to_namespaces":  []string{},
			"paused":               false,
			"scan_interval":        60000,
			"cutoff_relative_time": "-1d",
			"fields": map[string]interface{}{
				"MySource": "TestSourceTerraform",
			},
			"sumo_account_id": "926226587429",
			"collector_id":    "",
			"iam_details": map[string]interface{}{
				"create_iam_role": true,
				"iam_role_arn":    nil,
			},
		},
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 6, 0, 0)
	})

	vars = map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"collector_details": map[string]interface{}{
			"collector_name": "Test Updates Frst",
			"description":    "This collector is created for testing CloudTrail terraform module.",
			"fields": map[string]interface{}{
				"MyCollector": "TestTerraform",
			},
		},
		"source_details": map[string]interface{}{
			"source_name":          "Metrics Source",
			"source_category":      "Labs/cloudwatch/metrics",
			"description":          "This source is created using Sumo Logic terraform AWS CloudWatch Metrics module to collect AWS Cloudwatch metrics.",
			"limit_to_regions":     []string{"us-east-1"},
			"limit_to_namespaces":  []string{},
			"paused":               false,
			"scan_interval":        60000,
			"cutoff_relative_time": "-1d",
			"fields": map[string]interface{}{
				"MySource": "TestSourceTerraform",
			},
			"sumo_account_id": "926226587429",
			"collector_id":    "",
			"iam_details": map[string]interface{}{
				"create_iam_role": true,
				"iam_role_arn":    nil,
			},
		},
	}

	count = UpdateTerraform(t, vars, options)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "UpdateFirst", func() {
		common.AssertResourceCounts(t, count, 0, 1, 0)
	})

	vars = map[string]interface{}{
		"create_collector":          false,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"source_details": map[string]interface{}{
			"source_name":          "CloudWatch Metrics Source Another",
			"source_category":      "Labs/aws/cloudwatch/metrics",
			"description":          "This source is created using Sumo Logic terraform AWS CloudWatch Metrics module to collect AWS Cloudwatch metrics.",
			"limit_to_regions":     []string{"ap-south-1", "us-east-1"},
			"limit_to_namespaces":  []string{},
			"paused":               false,
			"scan_interval":        60000,
			"cutoff_relative_time": "-1d",
			"fields": map[string]interface{}{
				"MySource": "TestSourceTerraform",
			},
			"sumo_account_id": "926226587429",
			"collector_id":    COLLECTOR_ID,
			"iam_details": map[string]interface{}{
				"create_iam_role": true,
				"iam_role_arn":    nil,
			},
		},
	}

	count = UpdateTerraform(t, vars, options)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "UpdateFirst", func() {
		common.AssertResourceCounts(t, count, 1, 0, 2)
	})
}
