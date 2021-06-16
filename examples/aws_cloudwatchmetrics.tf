module "cloudwatchmetrics" {
  source = "../aws/cloudwatchmetrics"

  create_collector          = true
  sumologic_organization_id = "0000000000123456"
  collector_details = {
		"collector_name": "Test CloudWatch metrics Module One",
		"description":    "This is a new description.",
		"fields":         {
			"TestCollector": "MyValue"
    }
  }
  source_details = {
    source_name     = "CloudWatch Metrics Source"
    source_category = "Labs/aws/cloudwatch/metrics"
    description     = "This source is created using Sumo Logic terraform AWS CloudWatch Metrics module to collect AWS Cloudwatch metrics."
    collector_id    = ""
    limit_to_regions = [
    "us-east-1"]
    limit_to_namespaces = [
    "AWS/SNS"]
    scan_interval   = 300000
    paused          = false
    sumo_account_id = 926226587429
    fields          = {}
    iam_role_arn    = ""
  }
}