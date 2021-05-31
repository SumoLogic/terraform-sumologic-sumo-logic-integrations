package cloudtrail

import (
	"testing"
	"time"

	"github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/terratest/common"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

var replacementMap map[string]interface{}
var terraformOptions *terraform.Options
var resourceCount *terraform.ResourceCount

func SetUpTest(t *testing.T, vars map[string]interface{}) {
	awsRegion := common.AwsRegion

	envVars := map[string]string{
		"AWS_DEFAULT_REGION":    awsRegion,
		"SUMOLOGIC_ACCESSID":    common.SumologicAccessID,
		"SUMOLOGIC_ACCESSKEY":   common.SumologicAccessKey,
		"SUMOLOGIC_ENVIRONMENT": common.SumologicEnvironment,
	}

	replacementMap = map[string]interface{}{
		"AccountId":     common.AwsAccountId,
		"Region":        awsRegion,
		"SumoAccountId": common.SumoAccountId,
		"Deployment":    common.SumologicEnvironment,
		"OrgId":         common.SumologicOrganizationId,
	}

	terraformOptions, resourceCount = common.ApplyTerraformWithVars(t, vars, envVars)
	t.Cleanup(func() {
		common.CleanupTerraform(t, terraformOptions)
	})
}

func TestWithDefaultValues(t *testing.T) {
	t.Parallel()
	vars := map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_trail":              true,
	}

	SetUpTest(t, vars)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, resourceCount, 11, 0, 0)
	})

	// Assert if the outputs are actually created in AWS and Sumo Logic
	expectedOutputs := common.ReadJsonFile("defaultoutput.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, terraformOptions, expectedOutputs)
	})

	// Assert if the logs are sent to Sumo Logic.
	outputs := common.FetchAllOutputs(t, terraformOptions)
	common.GetAssertResource().CheckLogsForPastSixtyMinutes(t, outputs["sumologic_source"].(map[string]interface{})["id"].(string), 5, 2*time.Minute)
}
