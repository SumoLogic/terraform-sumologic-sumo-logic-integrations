package common

import (
	"fmt"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/stretchr/testify/assert"
)

func (a *ResourcesAssert) SUMOLOGIC_COLLECTOR(value interface{}) {
	fmt.Println("******** Asserting SUMOLOGIC COLLECTOR ********")
	ids := getKeyValuesFromData(value, "id")
	for _, element := range ids {
		err := http_helper.HTTPDoWithCustomValidationE(a.t, "GET",
			a.getCollectorURL(element), nil, a.SumoHeaders, customValidation, nil)
		assert.NoErrorf(a.t, err, "SUMOLOGIC COLLECTOR :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) SUMOLOGIC_SOURCE(value interface{}) {
	fmt.Println("******** Asserting SUMOLOGIC SOURCE ********")
	ids := getMultiKeyValuesFromData(value, []string{"collector_id", "id"})
	for _, element := range ids {
		err := http_helper.HTTPDoWithCustomValidationE(a.t, "GET",
			a.getSourceURL(element["collector_id"], element["id"]), nil, a.SumoHeaders, customValidation, nil)
		assert.NoErrorf(a.t, err, "SUMOLOGIC SOURCE :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) getCollectorURL(collectorId string) string {
	return fmt.Sprintf("%s/api/v1/collectors/%s", a.SumoLogicBaseApiUrl, collectorId)
}

func (a *ResourcesAssert) getSourceURL(collectorId, sourceId interface{}) string {
	return fmt.Sprintf("%s/api/v1/collectors/%v/sources/%v", a.SumoLogicBaseApiUrl, int(collectorId.(float64)), sourceId)
}
