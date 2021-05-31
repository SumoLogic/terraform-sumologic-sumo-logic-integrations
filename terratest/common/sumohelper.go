package common

import (
	"encoding/json"
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/stretchr/testify/assert"
)

func (a *ResourcesAssert) CheckLogsForPastSixtyMinutes(t *testing.T, query string, retries int, sleep time.Duration) {
	var body []map[string]interface{}
	tz, _ := time.Now().Zone()
	for i := 1; i <= retries; i++ {
		from := time.Now().Add(-60 * time.Minute).Format("2006-01-02T15:04:05")
		to := time.Now().Format("2006-01-02T15:04:05")
		out := http_helper.HTTPDoWithRetry(t, "GET", getSearchJobsURL(a.SumoLogicBaseApiUrl, query, from, to, tz),
			nil, a.SumoHeaders, 200, 1, 1*time.Second, nil)
		json.Unmarshal([]byte(out), &body)
		if len(body) <= 0 {
			fmt.Printf("Sleeping for %v and will retry with current counter as %v.", sleep.String(), i)
			time.Sleep(sleep)
		} else {
			break
		}
	}
	assert.Greater(t, len(body), 0, fmt.Sprintf("No messages found in the provided query {%s}", query))
}

func (a *ResourcesAssert) CheckLogsWithCustomFromAndToTime(t *testing.T, query, from, to, timeZone string,
	retries int, sleep time.Duration) {
	var body []map[string]interface{}
	for i := 1; i <= retries; i++ {
		out := http_helper.HTTPDoWithRetry(t, "GET", getSearchJobsURL(a.SumoLogicBaseApiUrl, query, from, to, timeZone),
			nil, a.SumoHeaders, 200, 1, 1*time.Second, nil)
		json.Unmarshal([]byte(out), &body)
		if len(body) <= 0 {
			fmt.Printf("Sleeping for %v and will retry with current counter as %v.", sleep.String(), i)
			time.Sleep(sleep)
		} else {
			break
		}
	}
	assert.Greater(t, len(body), 0, fmt.Sprintf("No messages found in the provided query {%s}", query))
}

func getSearchJobsURL(baseurl, query, from, to, timezone string) string {

	return fmt.Sprintf("%s/api/v1/logs/search?q=%s&from=%v&to=%v&tz=%v", baseurl, query, from, to, timezone)
}
