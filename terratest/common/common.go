package common

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"reflect"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// ReadJsonFile is used to read a JSON file and provide the output.
func ReadJsonFile(filePath string, replacementMap map[string]interface{}) map[string]interface{} {
	var expectedOutputs map[string]interface{}

	jsonFile, err := os.Open(filePath)
	// if we os.Open returns an error then handle it
	if err != nil {
		fmt.Println(err)
	}
	defer jsonFile.Close()

	byteValue, _ := ioutil.ReadAll(jsonFile)

	json.Unmarshal([]byte(log33(byteValue, replacementMap)), &expectedOutputs)

	return expectedOutputs
}

func log33(format []byte, replacementMap map[string]interface{}) string {
	args, i := make([]string, len(replacementMap)*2), 0
	for k, v := range replacementMap {
		args[i] = "{" + k + "}"
		args[i+1] = fmt.Sprint(v)
		i += 2
	}
	return strings.NewReplacer(args...).Replace(string(format))
}

// ApplyTerraformWithVars is used to Intialize, validate and apply the terraform module
// with custom input variables.
func ApplyTerraformWithVars(t *testing.T, vars map[string]interface{}, envVars map[string]string) (*terraform.Options, *terraform.ResourceCount) {

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../../" + ModuleDirectory,
		EnvVars:      envVars,
	})

	terraform.InitAndValidate(t, terraformOptions)

	terraformOptions.Vars = vars

	out := terraform.Apply(t, terraformOptions)

	count := terraform.GetResourceCount(t, out)

	return terraformOptions, count
}

func CleanupTerraform(t *testing.T, options *terraform.Options) {
	terraform.Destroy(t, options)
}

// FetchAllOutputs is used to fetch all outputs data when terraform is applied.
func FetchAllOutputs(t *testing.T, options *terraform.Options) map[string]interface{} {
	return terraform.OutputAll(t, options)
}

// ValidateResourceCounts is used to validate added, changed and destroyed resource count.
func AssertResourceCounts(t *testing.T, actualCount *terraform.ResourceCount, countAdd, countChange, countDestroy int) {
	assert.Equal(t, countAdd, actualCount.Add, "Mismatch in Added resources.")
	assert.Equal(t, countChange, actualCount.Change, "Mismatch in Changed resources.")
	assert.Equal(t, countDestroy, actualCount.Destroy, "Mismatch in Destroyed resources.")
}

// ValidateOutputs is used to validate all the outputs. This is an ever growing code which should be expanded
// to add various types of AWS and Sumo Logic outputs.
func AssertOutputs(t *testing.T, options *terraform.Options, expectedOutputs map[string]interface{}) {
	actualOutputs := FetchAllOutputs(t, options)

	// Assert length of outputs
	assert.Equal(t, len(actualOutputs), len(expectedOutputs), "Mismatch in number of outputs.")

	// Assert expected vs actual
	AssertObject(t, "", expectedOutputs, actualOutputs)

	// Assert / check by calling AWS and Sumo Logic APIs for actual outputs
	AssertAwsResources(t, actualOutputs)
}

// AssertObject is used to assert expected vs actual values based on object type.
// this a recursive method which will keep on calling array, maps and actual values.
func AssertObject(t *testing.T, expectedKey string, expectedValue interface{}, actualValue interface{}) {
	switch expectedValue := expectedValue.(type) {
	case []interface{}:
		for element := range expectedValue {
			AssertObject(t, "", expectedValue[element], FindType(element, actualValue))
		}
	case map[string]interface{}:
		for mapExpectedKey, mapExpectedValue := range expectedValue {
			actualOutputValue, found := actualValue.(map[string]interface{})[mapExpectedKey]
			assert.Equal(t, found, true, fmt.Sprintf("Expected output %v not found / created using terraform.", mapExpectedKey))
			AssertObject(t, mapExpectedKey, mapExpectedValue, actualOutputValue)
		}
	default:
		fmt.Printf("Compairing Key %v", expectedKey)
		assert.Equal(t, expectedValue, actualValue, fmt.Sprintf("Mismatch between actual value and expected values for key %v.", expectedKey))
	}
}

// FindType is used to identify element type and return values based on array or map.
func FindType(element int, value interface{}) interface{} {
	switch value := value.(type) {
	case []interface{}:
		return value[element]
	default:
		return value
	}
}

func AssertAwsResources(t *testing.T, outputs map[string]interface{}) {
	for key, value := range outputs {
		if strings.HasPrefix(key, "aws_") {
			v := reflect.ValueOf(assertaws)
			method := v.MethodByName(key)
			if method.IsValid() && !method.IsNil() && !method.IsZero() {
				method.Call(nil)
				fmt.Println(value)
			}
		}
	}
}
