package common

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var ModuleDirectory = os.Getenv("MODULE_DIRECTORY")
var SumologicAccessID = os.Getenv("SUMOLOGIC_ACCESS_ID")
var SumologicAccessKey = os.Getenv("SUMOLOGIC_ACCESS_KEY")
var SumologicEnvironment = os.Getenv("SUMOLOGIC_ENVIRONMENT")
var SumologicOrganizationId = os.Getenv("SUMOLOGIC_ORG_ID")
var AwsRegion = os.Getenv("AWS_REGION")

// ReadJsonFile is used to read a JSON file and provide the output.
func ReadJsonFile(filePath string) map[string]interface{} {
	var expectedOutputs map[string]interface{}

	jsonFile, err := os.Open(filePath)
	// if we os.Open returns an error then handle it
	if err != nil {
		fmt.Println(err)
	}
	defer jsonFile.Close()

	byteValue, _ := ioutil.ReadAll(jsonFile)
	json.Unmarshal([]byte(byteValue), &expectedOutputs)

	return expectedOutputs
}

// ApplyTerraformWithVars is used to Intialize, validate and apply the terraform module
// with custom input variables.
func ApplyTerraformWithVars(t *testing.T, vars map[string]interface{}) (*terraform.Options, *terraform.ResourceCount) {

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../" + ModuleDirectory,
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION":    AwsRegion,
			"SUMOLOGIC_ACCESSID":    SumologicAccessID,
			"SUMOLOGIC_ACCESSKEY":   SumologicAccessKey,
			"SUMOLOGIC_ENVIRONMENT": SumologicEnvironment,
		},
	})

	terraform.InitAndValidate(t, terraformOptions)

	terraformOptions.Vars = vars

	out := terraform.Apply(t, terraformOptions)

	count := terraform.GetResourceCount(t, out)

	return terraformOptions, count
}

// FetchAllOutputs is used to fetch all outputs data when terraform is applied.
func FetchAllOutputs(t *testing.T, terraformOptions *terraform.Options) map[string]interface{} {
	return terraform.OutputAll(t, terraformOptions)
}

// ValidateResourceCounts is used to validate added, changed and destroyed resource count.
func AssertResourceCounts(t *testing.T, actualCount *terraform.ResourceCount, countAdd, countChange, countDestroy int) {
	assert.Equal(t, actualCount.Add, countAdd, "Mismatch in Added resources.")
	assert.Equal(t, actualCount.Change, countChange, "Mismatch in Changed resources.")
	assert.Equal(t, actualCount.Destroy, countDestroy, "Mismatch in Destroyed resources.")
}

// ValidateOutputs is used to validate all the outputs. This is an ever growing code which should be expanded
// to add various types of AWS and Sumo Logic outputs.
func AssertOutputs(t *testing.T, terraformOptions *terraform.Options, expectedOutputs map[string]interface{}) {
	actualOutputs := FetchAllOutputs(t, terraformOptions)

	assert.Equal(t, len(actualOutputs), len(expectedOutputs), "Mismatch in number of outputs.")

	AssertObject(t, expectedOutputs, actualOutputs)
}

func AssertObject(t *testing.T, expectedValue interface{}, actualValue interface{}) {
	switch expectedValue := expectedValue.(type) {
	case []map[string]interface{}:
		for element := range expectedValue {
			AssertObject(t, element, actualValue)
		}
	case map[string]interface{}:
		for mapExpectedKey, mapExpectedValue := range expectedValue {
			actualOutputValue, found := actualValue.(map[string]interface{})[mapExpectedKey]
			assert.Equal(t, found, true, "Expected output not found / created using terraform.")
			AssertObject(t, mapExpectedValue, actualOutputValue)
		}
	default:
		assert.Contains(t, expectedValue, actualValue, "Mismatch between actual value and expected values.")
	}
}
