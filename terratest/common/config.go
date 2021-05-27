package common

import "os"

var ModuleDirectory = os.Getenv("MODULE_DIRECTORY")
var SumologicAccessID = os.Getenv("SUMOLOGIC_ACCESS_ID")
var SumologicAccessKey = os.Getenv("SUMOLOGIC_ACCESS_KEY")
var SumologicEnvironment = os.Getenv("SUMOLOGIC_ENVIRONMENT")
var SumologicOrganizationId = os.Getenv("SUMOLOGIC_ORG_ID")
var AwsRegion = os.Getenv("AWS_REGION")
var AwsAccountId = "668508221233"
var SumoAccountId = "926226587429"

var assertaws = AssertAws{}
