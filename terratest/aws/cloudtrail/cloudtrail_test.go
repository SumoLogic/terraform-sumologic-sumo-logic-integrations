package cloudtrail

import (
	"testing"

	"github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/terratest/common"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestWithDefaultValues(t *testing.T) {
	t.Parallel()
	vars := map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"create_trail":              true,
	}

	expectedOutputs := common.ReadJsonFile("defaultoutput.json")

	terraformOptions, count := common.ApplyTerraformWithVars(t, vars)
	defer terraform.Destroy(t, terraformOptions)

	// Assert count of Expected resources.
	common.AssertResourceCounts(t, count, 10, 0, 0)

	// Assert if the outputs are actually created in AWS and Sumo Logic
	common.AssertOutputs(t, terraformOptions, expectedOutputs)

	// Assert if the logs are sent to Sumo Logic.
}
