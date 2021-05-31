package common

import (
	"fmt"
	"testing"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/stretchr/testify/assert"
)

func (a *ResourcesAssert) SUMOLOGIC_COLLECTOR(t *testing.T, value interface{}) {
	fmt.Println("******** Asserting SUMOLOGIC COLLECTOR ********")
	ids := getKeyValuesFromData(value, "id")
	for _, element := range ids {
		err := http_helper.HTTPDoWithCustomValidationE(t, "GET",
			getCollectorURL(a.SumoLogicBaseApiUrl, element), nil, a.SumoHeaders, customValidation, nil)
		assert.NoErrorf(t, err, "SUMOLOGIC COLLECTOR :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) SUMOLOGIC_SOURCE(t *testing.T, value interface{}) {
	fmt.Println("******** Asserting SUMOLOGIC SOURCE ********")
	ids := getMultiKeyValuesFromData(value, []string{"collector_id", "id"})
	for _, element := range ids {
		err := http_helper.HTTPDoWithCustomValidationE(t, "GET",
			getSourceURL(a.SumoLogicBaseApiUrl, element["collector_id"], element["id"]), nil, a.SumoHeaders, customValidation, nil)
		assert.NoErrorf(t, err, "SUMOLOGIC SOURCE :- Error Message %v", err)
	}
}

func getCollectorURL(baseUrl, collectorId string) string {
	return fmt.Sprintf("%s/api/v1/collectors/%s", baseUrl, collectorId)
}

func getSourceURL(baseUrl string, collectorId, sourceId interface{}) string {
	return fmt.Sprintf("%s/api/v1/collectors/%v/sources/%v", baseUrl, int(collectorId.(float64)), sourceId)
}
