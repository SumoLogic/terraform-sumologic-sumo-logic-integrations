package sumologic

import (
	"fmt"
	"strings"
	"testing"

	"github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/terratest/common"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

var CONTENT_PATH = "/terratest/sumologic/testapp.json"

func getMetricRule(suffix string) map[string]interface{} {
	return map[string]interface{}{
		"metric_rule_name": fmt.Sprintf("MetricRule%s", suffix),
		"match_expression": fmt.Sprintf("%s=AWS/RDS DBClusterIdentifier=*", suffix),
		"sleep":            0,
		"variables_to_extract": []map[string]interface{}{
			{
				"name":        suffix,
				"tagSequence": "$DBClusterIdentifier._1",
			},
		},
	}
}

func getField(suffix string) map[string]interface{} {
	return map[string]interface{}{
		"field_name": fmt.Sprintf("field%s", suffix),
		"data_type":  "String",
		"state":      true}
}

func getFieldExtractionRule(suffix string) map[string]interface{} {
	return map[string]interface{}{
		"name":             fmt.Sprintf("FieldExtractionRule%s", suffix),
		"scope":            fmt.Sprintf("account=* eventname eventsource %s ", suffix),
		"parse_expression": " csv _raw extract 1 as user2, 2 as id, 3 as name | fields name",
		"enabled":          true,
	}
}

func getLogsMonitor(suffix, folderId string) map[string]interface{} {
	return map[string]interface{}{
		"monitor_name":         fmt.Sprintf("Monitor Name %s", suffix),
		"monitor_description":  fmt.Sprintf("This alert is %s.", suffix),
		"monitor_monitor_type": "Logs",
		"monitor_parent_id":    folderId,
		"monitor_is_disabled":  true,
		"queries": map[string]interface{}{
			"A": "account=* region=* dbidentifier=* | count by dbidentifier, namespace, region, account",
		},
		"triggers": []map[string]interface{}{
			{
				"detection_method": "StaticCondition",
				"trigger_type":     "Critical",
				"time_range":       "-5m",
				"threshold":        0,
				"threshold_type":   "GreaterThan",
				"occurrence_type":  "ResultCount",
				"trigger_source":   "AllResults",
			},
			{
				"detection_method": "StaticCondition",
				"trigger_type":     "ResolvedCritical",
				"time_range":       "-5m",
				"threshold":        0,
				"threshold_type":   "LessThanOrEqual",
				"occurrence_type":  "ResultCount",
				"trigger_source":   "AllResults",
			},
		},
		"group_notifications":      false,
		"connection_notifications": []map[string]interface{}{},
		"email_notifications":      []map[string]interface{}{},
	}
}

func getMetricsMonitor(suffix, folderId string) map[string]interface{} {
	return map[string]interface{}{
		"monitor_name":         fmt.Sprintf("Monitor Name %s", suffix),
		"monitor_description":  fmt.Sprintf("This alert is %s.", suffix),
		"monitor_monitor_type": "Metrics",
		"monitor_parent_id":    folderId,
		"monitor_is_disabled":  true,
		"queries": map[string]interface{}{
			"A": "account=* region=* dbidentifier=* | count by dbidentifier, namespace, region, account",
		},
		"triggers": []map[string]interface{}{
			{
				"detection_method": "StaticCondition",
				"trigger_type":     "Critical",
				"time_range":       "-5m",
				"threshold":        0,
				"threshold_type":   "GreaterThan",
				"occurrence_type":  "Always",
				"trigger_source":   "AnyTimeSeries",
			},
			{
				"detection_method": "StaticCondition",
				"trigger_type":     "ResolvedCritical",
				"time_range":       "-5m",
				"threshold":        0,
				"threshold_type":   "LessThanOrEqual",
				"occurrence_type":  "Always",
				"trigger_source":   "AnyTimeSeries",
			},
		},
		"group_notifications":      false,
		"connection_notifications": []map[string]interface{}{},
		"email_notifications":      []map[string]interface{}{},
	}
}

func getContent(contentPath, folderId string) map[string]interface{} {
	return map[string]interface{}{
		"content_json": contentPath,
		"folder_id":    folderId,
	}
}

func SetUpTest(t *testing.T, vars map[string]interface{}) (*terraform.Options, *terraform.ResourceCount) {
	envVars := map[string]string{
		"SUMOLOGIC_ACCESSID":    common.SumologicAccessID,
		"SUMOLOGIC_ACCESSKEY":   common.SumologicAccessKey,
		"SUMOLOGIC_ENVIRONMENT": common.SumologicEnvironment,
	}

	terraformOptions, resourceCount := common.ApplyTerraformWithVars(t, vars, envVars)

	return terraformOptions, resourceCount
}

func TestAllWithMultiInputs(t *testing.T) {
	t.Parallel()
	assertResource := common.GetAssertResource(t, nil)
	prefixOne := "AllInputsOne"
	prefixTwo := "AllInputsTwo"
	monitor_folder_id := assertResource.CreateAndGetMonitorFolderIdFromPersonal(prefixOne)
	app_folder_id_one := assertResource.CreateAndGetFolderIdFromPersonal(prefixOne)
	app_folder_id_two := assertResource.CreateAndGetFolderIdFromPersonal(prefixTwo)
	t.Cleanup(func() {
		assertResource.DeleteFolder(app_folder_id_one)
		assertResource.DeleteFolder(app_folder_id_two)
		assertResource.DeleteMonitorFolder(monitor_folder_id)
	})

	replacementMap := map[string]interface{}{
		"Parent_App_Id_One": app_folder_id_one,
		"Parent_App_Id_Two": app_folder_id_two,
	}
	vars := map[string]interface{}{
		"access_id":   common.SumologicAccessID,
		"access_key":  common.SumologicAccessKey,
		"environment": common.SumologicEnvironment,
		"managed_metric_rules": map[string]interface{}{
			"MetricRuleOne": getMetricRule(prefixOne),
			"MetricRuleTwo": getMetricRule(prefixTwo),
		},
		"managed_fields": map[string]interface{}{
			"FieldOne": getField(strings.ToLower(prefixOne)),
			"FieldTwo": getField(strings.ToLower(prefixTwo)),
		},
		"managed_field_extraction_rules": map[string]interface{}{
			"FieldExtractionRuleOne": getFieldExtractionRule(prefixOne),
			"FieldExtractionRuleTwo": getFieldExtractionRule(prefixTwo),
		},
		"managed_apps": map[string]interface{}{
			"AppOne": getContent(CONTENT_PATH, app_folder_id_one),
			"AppTwo": getContent(CONTENT_PATH, app_folder_id_two),
		},
		"managed_monitors": map[string]interface{}{
			"MonitorOne": getLogsMonitor(prefixOne, monitor_folder_id),
			"MonitorTwo": getMetricsMonitor(prefixTwo, monitor_folder_id),
		},
	}

	options, count := SetUpTest(t, vars)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 10, 0, 0)
	})

	expectedOutputs := common.ReadJsonFile("TestAllWithMultiInputs.json", replacementMap)
	test_structure.RunTestStage(t, "AssertOutputs", func() {
		common.AssertOutputs(t, options, expectedOutputs)
	})
}

func TestMetricRuleOnly(t *testing.T) {

	vars := map[string]interface{}{
		"access_id":   common.SumologicAccessID,
		"access_key":  common.SumologicAccessKey,
		"environment": common.SumologicEnvironment,
		"managed_metric_rules": map[string]interface{}{
			"MetricRuleOne": getMetricRule("TestMetricRuleOnly"),
		},
	}

	options, count := SetUpTest(t, vars)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 1, 0, 0)
	})

	test_structure.RunTestStage(t, "AssertOutputs", func() {
		actualOutputs := common.FetchAllOutputs(t, options)
		common.AssertResources(t, actualOutputs, options)
	})
}

func TestFieldsOnly(t *testing.T) {
	t.Parallel()

	vars := map[string]interface{}{
		"access_id":   common.SumologicAccessID,
		"access_key":  common.SumologicAccessKey,
		"environment": common.SumologicEnvironment,
		"managed_fields": map[string]interface{}{
			"FieldOne": getField("testfieldonly"),
		},
	}

	options, count := SetUpTest(t, vars)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 1, 0, 0)
	})

	test_structure.RunTestStage(t, "AssertOutputs", func() {
		actualOutputs := common.FetchAllOutputs(t, options)
		common.AssertResources(t, actualOutputs, options)
	})
}

func TestFieldExtractionRuleOnly(t *testing.T) {
	t.Parallel()

	vars := map[string]interface{}{
		"access_id":   common.SumologicAccessID,
		"access_key":  common.SumologicAccessKey,
		"environment": common.SumologicEnvironment,
		"managed_field_extraction_rules": map[string]interface{}{
			"FieldExtractionRuleOne": getFieldExtractionRule("TestFieldExtractionRuleOnly"),
		},
	}

	options, count := SetUpTest(t, vars)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 1, 0, 0)
	})

	test_structure.RunTestStage(t, "AssertOutputs", func() {
		actualOutputs := common.FetchAllOutputs(t, options)
		common.AssertResources(t, actualOutputs, options)
	})
}

func TestContentOnly(t *testing.T) {
	t.Parallel()

	assertResource := common.GetAssertResource(t, nil)
	prefixOne := "TestContentOnly"
	app_folder_id_one := assertResource.CreateAndGetFolderIdFromPersonal(prefixOne)
	t.Cleanup(func() {
		assertResource.DeleteFolder(app_folder_id_one)
	})

	vars := map[string]interface{}{
		"access_id":   common.SumologicAccessID,
		"access_key":  common.SumologicAccessKey,
		"environment": common.SumologicEnvironment,
		"managed_apps": map[string]interface{}{
			"AppOne": getContent(CONTENT_PATH, app_folder_id_one),
		},
	}

	options, count := SetUpTest(t, vars)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 1, 0, 0)
	})

	test_structure.RunTestStage(t, "AssertOutputs", func() {
		actualOutputs := common.FetchAllOutputs(t, options)
		common.AssertResources(t, actualOutputs, options)
	})
}

func TestMonitorsOnly(t *testing.T) {
	t.Parallel()

	assertResource := common.GetAssertResource(t, nil)
	prefixOne := "TestMonitorsOnly"
	monitor_folder_id := assertResource.CreateAndGetMonitorFolderIdFromPersonal(prefixOne)
	t.Cleanup(func() {
		assertResource.DeleteMonitorFolder(monitor_folder_id)
	})

	vars := map[string]interface{}{
		"access_id":   common.SumologicAccessID,
		"access_key":  common.SumologicAccessKey,
		"environment": common.SumologicEnvironment,
		"managed_monitors": map[string]interface{}{
			"MonitorOne": getLogsMonitor(prefixOne, monitor_folder_id),
		},
	}

	options, count := SetUpTest(t, vars)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 1, 0, 0)
	})

	test_structure.RunTestStage(t, "AssertOutputs", func() {
		actualOutputs := common.FetchAllOutputs(t, options)
		common.AssertResources(t, actualOutputs, options)
	})
}

func UpdateTerraform(t *testing.T, vars map[string]interface{}, options *terraform.Options) *terraform.ResourceCount {
	options.Vars = vars
	out := terraform.Apply(t, options)
	return terraform.GetResourceCount(t, out)
}

func TestUpdatesOnly(t *testing.T) {

	vars := map[string]interface{}{
		"access_id":   common.SumologicAccessID,
		"access_key":  common.SumologicAccessKey,
		"environment": common.SumologicEnvironment,
		"managed_metric_rules": map[string]interface{}{
			"MetricRuleOne": getMetricRule("TestMetricRuleUpdateOneOnly"),
		},
	}

	options, count := SetUpTest(t, vars)

	// Assert count of Expected resources.
	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 1, 0, 0)
	})

	test_structure.RunTestStage(t, "AssertOutputs", func() {
		actualOutputs := common.FetchAllOutputs(t, options)
		common.AssertResources(t, actualOutputs, options)
	})

	vars = map[string]interface{}{
		"access_id":   common.SumologicAccessID,
		"access_key":  common.SumologicAccessKey,
		"environment": common.SumologicEnvironment,
		"managed_metric_rules": map[string]interface{}{
			"MetricRuleOne": getMetricRule("TestMetricRuleUpdayesTwo"),
		},
	}

	count = UpdateTerraform(t, vars, options)

	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 1, 0, 1)
	})

	vars = map[string]interface{}{
		"access_id":   common.SumologicAccessID,
		"access_key":  common.SumologicAccessKey,
		"environment": common.SumologicEnvironment,
		"managed_field_extraction_rules": map[string]interface{}{
			"FieldExtractionRuleOne": getFieldExtractionRule("TestUpdatesOnly"),
		},
	}

	count = UpdateTerraform(t, vars, options)

	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 1, 0, 1)
	})

	vars = map[string]interface{}{
		"access_id":   common.SumologicAccessID,
		"access_key":  common.SumologicAccessKey,
		"environment": common.SumologicEnvironment,
		"managed_field_extraction_rules": map[string]interface{}{
			"FieldExtractionRuleOne": getFieldExtractionRule("TestUpdatesOnlyAgain"),
		},
	}

	count = UpdateTerraform(t, vars, options)

	test_structure.RunTestStage(t, "AssertCount", func() {
		common.AssertResourceCounts(t, count, 0, 1, 0)
	})
}
