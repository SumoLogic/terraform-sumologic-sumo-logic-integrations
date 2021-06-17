package rootcause

import (
	"os"
	"testing"

	"github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/terratest/common"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

var LOOK_UP_MAP = map[string]string{"inventory_sumologic_source": "sumologic_source", "xray_sumologic_source": "sumologic_source"}
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
		"create_inventory_source":   true,
		"create_xray_source":        true,
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 7, 0, 0)
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
		common.AssertOutputsWithLookup(t, options, expectedOutputs, LOOK_UP_MAP)
	})
}

func TestXraySourceOnlyWithNewCollector(t *testing.T) {
	t.Parallel()
	aws_region := "us-east-1"
	vars := map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_inventory_source":   false,
		"create_xray_source":        true,
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
	expectedOutputs := common.ReadJsonFile("TestXraySourceOnlyWithNewCollector.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputsWithLookup(t, options, expectedOutputs, LOOK_UP_MAP)
	})
}

func TestInventorySourceOnlyWithExistingCollector(t *testing.T) {
	t.Parallel()
	aws_region := "us-west-1"
	vars := map[string]interface{}{
		"create_collector":          false,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_inventory_source":   true,
		"inventory_source_details": map[string]interface{}{
			"source_name":     "My Inventory Source",
			"source_category": "My/Test/cvategory",
			"collector_id":    COLLECTOR_ID,
			"description":     "This is description.",
			"fields": map[string]string{
				"TestCollector": "MyValue",
			},
			"sumo_account_id":     "926226587429",
			"limit_to_regions":    []string{"us-east-1"},
			"limit_to_namespaces": []string{"AWS/SNS", "AWS/SQS", "AWS/Events", "AWS/Lambda", "AWS/Logs", "AWS/S3", "AWS/Firehose"},
			"iam_role_arn":        "",
			"paused":              false,
			"scan_interval":       60000,
		},
		"create_xray_source": false,
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 5, 0, 0)
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
	expectedOutputs := common.ReadJsonFile("TestInventorySourceOnlyWithExistingCollector.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputsWithLookup(t, options, expectedOutputs, LOOK_UP_MAP)
	})
}

func TestWithExistingValues(t *testing.T) {
	t.Parallel()
	aws_region := "us-west-2"
	vars := map[string]interface{}{
		"create_collector":          false,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_inventory_source":   true,
		"inventory_source_details": map[string]interface{}{
			"source_name":     "My Inventory Source Another",
			"source_category": "My/Test/cvategory",
			"collector_id":    COLLECTOR_ID,
			"description":     "This is description.",
			"fields": map[string]string{
				"TestCollector": "MyValue",
			},
			"sumo_account_id":     "926226587429",
			"limit_to_regions":    []string{"us-east-2"},
			"limit_to_namespaces": []string{"AWS/SNS", "AWS/SQS"},
			"paused":              false,
			"scan_interval":       60000,
		},
		"create_xray_source": true,
		"xray_source_details": map[string]interface{}{
			"source_name":     "My Xray Source Another",
			"source_category": "My/Test/cvategory",
			"collector_id":    COLLECTOR_ID,
			"description":     "This is description.",
			"fields": map[string]string{
				"TestCollector": "MyValue",
			},
			"sumo_account_id":  "926226587429",
			"limit_to_regions": []string{"ap-south-1"},
			"paused":           false,
			"scan_interval":    60000,
		},
		"aws_iam_role_arn": IAM_ROLE,
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 4, 0, 0)
	})

	outputs := common.FetchAllOutputs(t, options)
	replacementMap := map[string]interface{}{
		"AccountId":     aws.GetAccountId(t),
		"Region":        aws_region,
		"SumoAccountId": common.SumoAccountId,
		"Deployment":    common.SumologicEnvironment,
		"OrgId":         common.SumologicOrganizationId,
		"RandomString":  outputs["random_string"].(map[string]interface{})["id"].(string),
		"ROLE_ARN":      IAM_ROLE,
	}

	// Assert if the outputs are actually created in AWS and Sumo Logic.
	// This also checks if your expectation are matched with the outputs, so provide an JSON with expected outputs.
	expectedOutputs := common.ReadJsonFile("TestWithExistingValues.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputsWithLookup(t, options, expectedOutputs, LOOK_UP_MAP)
	})
}

func TestUpdates(t *testing.T) {
	t.Parallel()
	aws_region := "ap-south-1"
	vars := map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_inventory_source":   true,
		"create_xray_source":        true,
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 7, 0, 0)
	})

	vars = map[string]interface{}{
		"create_collector": true,
		"collector_details": map[string]interface{}{
			"collector_name": "Test Root Cause Updates",
			"description":    "This collector is created for testing elb terraform module.",
			"fields": map[string]interface{}{
				"MyCollector": "TestTerraform",
			},
		},
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_inventory_source":   true,
		"create_xray_source":        true,
	}

	count = UpdateTerraform(t, vars, options)

	test_structure.RunTestStage(t, "UpdateFirst", func() {
		common.AssertResourceCounts(t, count, 0, 1, 0)
	})

	vars = map[string]interface{}{
		"create_collector":          false,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_inventory_source":   true,
		"inventory_source_details": map[string]interface{}{
			"source_name":     "My Inventory Source One More",
			"source_category": "My/Test/cvategory",
			"collector_id":    COLLECTOR_ID,
			"description":     "This is description.",
			"fields": map[string]string{
				"TestCollector": "MyValue",
			},
			"sumo_account_id":     "926226587429",
			"limit_to_regions":    []string{"us-east-1"},
			"limit_to_namespaces": []string{"AWS/SNS", "AWS/SQS", "AWS/Events", "AWS/Lambda", "AWS/Logs", "AWS/S3", "AWS/Firehose"},
			"iam_role_arn":        "",
			"paused":              false,
			"scan_interval":       60000,
		},
		"create_xray_source": false,
	}

	count = UpdateTerraform(t, vars, options)

	test_structure.RunTestStage(t, "UpdateFirst", func() {
		common.AssertResourceCounts(t, count, 1, 0, 3)
	})
}
