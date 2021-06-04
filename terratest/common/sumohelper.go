package common

import (
	"encoding/json"
	"fmt"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/stretchr/testify/assert"
)

func (a *ResourcesAssert) CheckLogsForPastSixtyMinutes(query string, retries int, sleep time.Duration) {
	var body []map[string]interface{}
	tz, _ := time.Now().Zone()
	for i := 1; i <= retries; i++ {
		from := time.Now().Add(-60 * time.Minute).Format("2006-01-02T15:04:05")
		to := time.Now().Format("2006-01-02T15:04:05")
		out := http_helper.HTTPDoWithRetry(a.t, "GET", a.getSearchJobsURL(query, from, to, tz),
			nil, a.SumoHeaders, 200, 1, 1*time.Second, nil)
		json.Unmarshal([]byte(out), &body)
		if len(body) <= 0 {
			fmt.Printf("Sleeping for %v and will retry with current counter as %v.", sleep.String(), i)
			time.Sleep(sleep)
		} else {
			break
		}
	}
	assert.Greater(a.t, len(body), 0, fmt.Sprintf("No messages found in the provided query {%s}", query))
}

func (a *ResourcesAssert) CheckLogsWithCustomFromAndToTime(query, from, to, timeZone string,
	retries int, sleep time.Duration) {
	var body []map[string]interface{}
	for i := 1; i <= retries; i++ {
		out := http_helper.HTTPDoWithRetry(a.t, "GET", a.getSearchJobsURL(query, from, to, timeZone),
			nil, a.SumoHeaders, 200, 1, 1*time.Second, nil)
		json.Unmarshal([]byte(out), &body)
		if len(body) <= 0 {
			fmt.Printf("Sleeping for %v and will retry with current counter as %v.", sleep.String(), i)
			time.Sleep(sleep)
		} else {
			break
		}
	}
	assert.Greater(a.t, len(body), 0, fmt.Sprintf("No messages found in the provided query {%s}", query))
}

func (a *ResourcesAssert) CheckMetricsForPastSixtyMinutes(query string, retries int, sleep time.Duration) {
	var body map[string]interface{}
	count := 0
	tz, _ := time.Now().Zone()
	for i := 1; i <= retries; i++ {
		from := time.Now().Add(-60 * time.Minute).Sub(time.Unix(0, 0)).Milliseconds()
		to := time.Now().Add(1 * time.Second).Sub(time.Unix(0, 0)).Milliseconds()
		request, _ := json.Marshal(map[string]interface{}{"query": []map[string]interface{}{{"query": query, "rowId": "A", "timezone": tz}}, "startTime": from, "endTime": to, "desiredQuantizationInSecs": 5})
		out := http_helper.HTTPDoWithRetry(a.t, "POST", a.getMetricResultsURL(), request, a.SumoHeaders, 200, 1, 1*time.Second, nil)
		json.Unmarshal([]byte(out), &body)
		response := body["response"]
		if len(response.([]interface{})) <= 0 {
			fmt.Printf("Sleeping for %v and will retry with current counter as %v.", sleep.String(), i)
			time.Sleep(sleep)
		} else {
			count = len(response.([]interface{}))
			break
		}
	}
	assert.Greater(a.t, count, 0, fmt.Sprintf("No messages found in the provided query {%s}", query))
}

func (a *ResourcesAssert) CreateAndGetFolderIdFromPersonal(folder_name string) string {
	personal_folder_id := a.GetPersonalFolder()
	requestBody, _ := json.Marshal(map[string]interface{}{"name": folder_name, "description": "This is a folder.", "parentId": personal_folder_id})
	out := http_helper.HTTPDoWithRetry(a.t, "POST", a.getContentURL()+"/folders", requestBody, a.SumoHeaders, 200, 1, 1*time.Second, nil)
	id := getId(out)
	a.t.Cleanup(func() {
		a.DeleteFolder(id)
	})
	return id
}

func (a *ResourcesAssert) CreateAndGetMonitorFolderIdFromPersonal(folder_name string) string {
	root_folder_id := a.GetRootMonitorFolder()
	requestBody, _ := json.Marshal(map[string]interface{}{"name": folder_name, "description": "This is a folder.", "type": "MonitorsLibraryFolder"})
	out := http_helper.HTTPDoWithRetry(a.t, "POST", a.getMonitorsFoldersURL()+"?parentId="+root_folder_id, requestBody, a.SumoHeaders, 200, 1, 1*time.Second, nil)
	id := getId(out)
	a.t.Cleanup(func() {
		a.DeleteMonitorFolder(id)
	})
	return id
}

func (a *ResourcesAssert) DeleteFolder(folderId string) {
	http_helper.HTTPDo(a.t, "DELETE", a.getContentURL()+"/"+folderId+"/delete", nil, a.SumoHeaders, nil)
}

func (a *ResourcesAssert) DeleteMonitorFolder(folderId string) {
	http_helper.HTTPDo(a.t, "DELETE", a.getMonitorsFoldersURL()+"/"+folderId, nil, a.SumoHeaders, nil)
}

func (a *ResourcesAssert) GetPersonalFolder() string {
	out := http_helper.HTTPDoWithRetry(a.t, "GET", a.getContentURL()+"/folders/personal", nil, a.SumoHeaders, 200, 1, 1*time.Second, nil)
	return getId(out)
}

func (a *ResourcesAssert) GetRootMonitorFolder() string {
	out := http_helper.HTTPDoWithRetry(a.t, "GET", a.getMonitorsFoldersURL()+"/root", nil, a.SumoHeaders, 200, 1, 1*time.Second, nil)
	return getId(out)
}

func getId(stringBody string) string {
	var body map[string]interface{}
	json.Unmarshal([]byte(stringBody), &body)
	return body["id"].(string)
}

func (a *ResourcesAssert) getContentURL() string {
	return fmt.Sprintf("%s/api/v2/content", a.SumoLogicBaseApiUrl)
}

func (a *ResourcesAssert) getMonitorsFoldersURL() string {
	return fmt.Sprintf("%s/api/v1/monitors", a.SumoLogicBaseApiUrl)
}

func (a *ResourcesAssert) getSearchJobsURL(query, from, to, timezone string) string {
	return fmt.Sprintf("%s/api/v1/logs/search?q=%s&from=%v&to=%v&tz=%v", a.SumoLogicBaseApiUrl, query, from, to, timezone)
}

func (a *ResourcesAssert) getMetricResultsURL() string {
	return fmt.Sprintf("%s/api/v1/metrics/results", a.SumoLogicBaseApiUrl)
}
