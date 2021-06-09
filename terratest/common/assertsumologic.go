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

func (a *ResourcesAssert) SUMOLOGIC_FIELD(value interface{}) {
	fmt.Println("******** Asserting SUMOLOGIC FIELDS ********")
	ids := getKeyValuesFromData(value, "id")
	for _, element := range ids {
		err := http_helper.HTTPDoWithCustomValidationE(a.t, "GET", a.getFieldURL(element),
			nil, a.SumoHeaders, customValidation, nil)
		assert.NoErrorf(a.t, err, "SUMOLOGIC FIELD :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) SUMOLOGIC_FIELD_EXTRACTION_RULE(value interface{}) {
	fmt.Println("******** Asserting SUMOLOGIC EXTRACTION RULE ********")
	ids := getKeyValuesFromData(value, "id")
	for _, element := range ids {
		err := http_helper.HTTPDoWithCustomValidationE(a.t, "GET", a.getFieldExtractionURL(element),
			nil, a.SumoHeaders, customValidation, nil)
		assert.NoErrorf(a.t, err, "SUMOLOGIC EXTRACTION RULE :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) SUMOLOGIC_CONTENT(value interface{}) {
	fmt.Println("******** Asserting SUMOLOGIC CONTENT ********")
	ids := getKeyValuesFromData(value, "id")
	for _, element := range ids {
		err := http_helper.HTTPDoWithCustomValidationE(a.t, "GET", a.getContentURL()+"/folders/"+element,
			nil, a.SumoHeaders, customValidation, nil)
		assert.NoErrorf(a.t, err, "SUMOLOGIC CONTENT :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) SUMOLOGIC_METRIC_RULES(value interface{}) {
	fmt.Println("******** Asserting SUMOLOGIC METRIC RULES ********")
	ids := getMultiKeyValuesFromData(value, []string{"triggers"})
	for _, element := range ids {
		triggers := element["triggers"].(map[string]interface{})
		err := http_helper.HTTPDoWithCustomValidationE(a.t, "GET", a.getMetricRulesURL(triggers["name"].(string)),
			nil, a.SumoHeaders, customValidation, nil)
		assert.NoErrorf(a.t, err, "SUMOLOGIC METRIC RULES :- Error Message %v", err)
	}
}

func (a *ResourcesAssert) getMetricRulesURL(ruleId string) string {
	return fmt.Sprintf("%s/api/v1/metricsRules/%s", a.SumoLogicBaseApiUrl, ruleId)
}

func (a *ResourcesAssert) getFieldExtractionURL(ruleId string) string {
	return fmt.Sprintf("%s/api/v1/extractionRules/%s", a.SumoLogicBaseApiUrl, ruleId)
}

func (a *ResourcesAssert) getFieldURL(fieldId string) string {
	return fmt.Sprintf("%s/api/v1/fields/%s", a.SumoLogicBaseApiUrl, fieldId)
}

func (a *ResourcesAssert) getCollectorURL(collectorId string) string {
	return fmt.Sprintf("%s/api/v1/collectors/%s", a.SumoLogicBaseApiUrl, collectorId)
}

func (a *ResourcesAssert) getSourceURL(collectorId, sourceId interface{}) string {
	return fmt.Sprintf("%s/api/v1/collectors/%v/sources/%v", a.SumoLogicBaseApiUrl, int(collectorId.(float64)), sourceId)
}
