package common

import (
	"os"
)

var ModuleDirectory = os.Getenv("MODULE_DIRECTORY")
var SumologicAccessID = os.Getenv("SUMOLOGIC_ACCESS_ID")
var SumologicAccessKey = os.Getenv("SUMOLOGIC_ACCESS_KEY")
var SumologicEnvironment = os.Getenv("SUMOLOGIC_ENVIRONMENT")
var SumologicOrganizationId = os.Getenv("SUMOLOGIC_ORG_ID")

var SumoAccountId = "926226587429"

type ResourcesAssert struct {
	AwsRegion           string
	SumoHeaders         map[string]string
	SumoLogicBaseApiUrl string
}

var customValidation = func(statusCode int, body string) bool { return statusCode == 200 }
