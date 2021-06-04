package elb

import (
	"fmt"
	"net/http"
	"testing"
	"time"

	"github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/terratest/common"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

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

func TestWithDefaultValues(t *testing.T) {
	t.Parallel()
	aws_region := "us-east-2"
	replacementMap := map[string]interface{}{
		"AccountId":     aws.GetAccountId(t),
		"Region":        aws_region,
		"SumoAccountId": common.SumoAccountId,
		"Deployment":    common.SumologicEnvironment,
		"OrgId":         common.SumologicOrganizationId,
	}
	vars := map[string]interface{}{
		"create_collector":          true,
		"sumologic_organization_id": common.SumologicOrganizationId,
		"auto_enable_access_logs":   "Both",
	}

	options, count := SetUpTest(t, vars, aws_region)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 10, 0, 0)
	})

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
	outputs := common.FetchAllOutputs(t, options)
	assertResource.ValidateLoadBalancerAccessLogs(lb_id, outputs["aws_s3_bucket"].(map[string]interface{})["s3_bucket"].(map[string]interface{})["bucket"].(string))
	assertResource.CheckLogsForPastSixtyMinutes("_sourceid="+outputs["sumologic_source"].(map[string]interface{})["id"].(string), 5, 2*time.Minute)
}
