package common

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/url"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
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

func isValidJSONStr(s string) bool {
	s = strings.TrimSpace(s)
	if s == "" {
		return false
	}
	return json.Valid([]byte(s))
}

func toJSONString(v any) (string, bool) {
	switch x := v.(type) {
	case string:
		return x, true
	default:
		b, err := json.Marshal(v)
		if err != nil {
			return "", false
		}
		return string(b), true
	}
}

// ApplyTerraformWithVars is used to Intialize, validate and apply the terraform module
// with custom input variables.
func ApplyTerraformWithVars(t *testing.T, vars map[string]interface{}, envVars map[string]string) (*terraform.Options, *terraform.ResourceCount) {
	dir, _ := os.Getwd()
	dir = filepath.Dir(strings.ReplaceAll(dir, "/"+ModuleDirectory, ""))
	directory := test_structure.CopyTerraformFolderToTemp(t, dir, ModuleDirectory)
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: directory,
		EnvVars:      envVars,
	})

	terraform.InitAndValidate(t, terraformOptions)

	terraformOptions.Vars = vars

	t.Cleanup(func() {
		CleanupTerraform(t, terraformOptions)
	})

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
	AssertOutputsWithLookup(t, options, expectedOutputs, map[string]string{})
}

// AssertOutputsWithLookup takes up lookup map to find out the method names based on key and value.
func AssertOutputsWithLookup(t *testing.T, options *terraform.Options, expectedOutputs map[string]interface{}, lookupmap map[string]string) {
	actualOutputs := FetchAllOutputs(t, options)

	// Assert length of outputs
	assert.Equal(t, len(expectedOutputs), len(actualOutputs), "Mismatch in number of outputs.")

	// Assert expected vs actual
	AssertObject(t, "", expectedOutputs, actualOutputs)

	// Assert check by calling AWS and Sumo Logic APIs for actual outputs
	AssertResources(t, actualOutputs, options, lookupmap)
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
			if actualValue != nil {
				actualOutputValue, found := actualValue.(map[string]interface{})[mapExpectedKey]
				assert.Equal(t, found, true, fmt.Sprintf("Expected output %v not found / created using terraform.", mapExpectedKey))
				AssertObject(t, mapExpectedKey, mapExpectedValue, actualOutputValue)
			} else {
				assert.Equal(t, mapExpectedValue, actualValue, fmt.Sprintf("Expected output %v not found / created using terraform.", mapExpectedKey))
			}
		}
	default:
		fmt.Println("**** Compairing Key { " + expectedKey + " } ****")

        // If expected is a (non-empty, valid) JSON string, compare as JSON
        if es, ok := expectedValue.(string); ok && isValidJSONStr(es) {
            as, ok2 := toJSONString(actualValue)
            if !ok2 || !isValidJSONStr(as) {
                // Decide what you want here: strict fail or fallback to raw equality
                require.Failf(t,
                    "invalid actual JSON",
                    "key %s: expected valid JSON, but actual isn't valid JSON/stringifies \nactual: %#v",
                    expectedKey, actualValue)
            }
            require.JSONEqf(t, es, as, "key %s: JSON mismatch", expectedKey)
        }else {
            assert.Equal(t, expectedValue, actualValue, fmt.Sprintf("Mismatch between actual value and expected values for key %v.", expectedKey))
        }
	}
}

// FindType is used to identify element type and return values based on array or map.
func FindType(element int, value interface{}) interface{} {
	switch value := value.(type) {
	case []interface{}:
		if len(value) > 0 {
			return value[element]
		} else {
			return value
		}
	default:
		return value
	}
}

// AssertResources is used to call methods based on the Terraform resource types.
// Methods are in UpperCases to keep them public.
func AssertResources(t *testing.T, outputs map[string]interface{}, options *terraform.Options, lookupmap map[string]string) {
	resourcesAssert := GetAssertResource(t, options.EnvVars)
	for key, value := range outputs {
		myClassValue := reflect.ValueOf(resourcesAssert)
		methodName, found := lookupmap[key]
		var m reflect.Value
		if found {
			m = myClassValue.MethodByName(strings.ToUpper(methodName))
		} else {
			m = myClassValue.MethodByName(strings.ToUpper(key))
		}
		in := make([]reflect.Value, 1)
		in[0] = reflect.ValueOf(value)
		if m.IsValid() {
			m.Call(in)
		}
	}
}

// getAssertResource is to create an AssertResource object
func GetAssertResource(t *testing.T, envVars map[string]string) *ResourcesAssert {
	var awsRegion string
	if envVars != nil {
		awsRegion = envVars["AWS_DEFAULT_REGION"]
	}
	return &ResourcesAssert{
		t:         t,
		AwsRegion: awsRegion,
		SumoHeaders: map[string]string{
			"Authorization": "Basic " + base64.StdEncoding.EncodeToString([]byte(SumologicAccessID+":"+SumologicAccessKey)),
			"Content-Type":  "application/json",
		},
		SumoLogicBaseApiUrl: getSumologicURL(),
	}
}

// getSumologicURL is used to get the sumologic URL based on the Environment .
func getSumologicURL() string {
	api_url := ""
	if SumologicEnvironment == "us1" {
		api_url = "https://api.sumologic.com/api/"
	} else {
		api_url = fmt.Sprintf("https://api.%s.sumologic.com/api/", SumologicEnvironment)
	}
	u, _ := url.Parse(api_url)
	return u.Scheme + "://" + u.Host
}

// getKeyValuesFromData is used to get values from a particular key by iterating through the given data.
func getKeyValuesFromData(value interface{}, key string) []string {
	var values []string
	mapValue := value.(map[string]interface{})
	keyValue, found := mapValue[key]
	if found {
		values = append(values, keyValue.(string))
	} else {
		for currentKey, currentValue := range mapValue {
			fmt.Println("Searching for KEY { " + key + " } in terraform resource { " + currentKey + " }.")
			keyValue, found := currentValue.(map[string]interface{})[key]
			if found {
				values = append(values, keyValue.(string))
			}
		}
	}
	return values
}

// getMultiKeyValuesFromData is used to get values from a multiple key by iterating through the given data.
func getMultiKeyValuesFromData(value interface{}, keys []string) []map[string]interface{} {
	var values []map[string]interface{}
	mapValue := value.(map[string]interface{})
	_, found := mapValue[keys[0]]
	if found {
		data := make(map[string]interface{}, len(keys))
		for _, currentKey := range keys {
			data[currentKey] = mapValue[currentKey]
		}
		values = append(values, data)
	} else {
		for currentKey, currentValue := range mapValue {
			data := make(map[string]interface{}, len(keys))
			for _, expectedKey := range keys {
				fmt.Println("Searching for KEY { " + expectedKey + " } in terraform resource { " + currentKey + " }.")
				data[expectedKey] = currentValue.(map[string]interface{})[expectedKey]
			}
			values = append(values, data)
		}
	}
	return values
}
