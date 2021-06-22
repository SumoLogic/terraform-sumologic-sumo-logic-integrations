module "cloudwatchlogsforwarder" {
  source = "../aws/cloudwatchlogsforwarder"

  create_collector = true
  collector_details = {
    collector_name = "CloudWatch Collector Example"
    description    = "This is an example for cloudwatch collector"
    fields = {
      "TestCollector" = "MyValue"
    }
  }

  source_details = {
    source_name     = "Cloudwatch source"
    source_category = "Labs/cloudwatch/logs"
    description     = "This is an description."
    collector_id    = ""
    fields = {
      "account" : "MyValue"
      "region" : "us-east-1"
      "namespace" : "AWS/Lambda"
    }
  }

  // Lambda options
  email_id               = "sourabh@sumologic.com"
  workers                = 5
  include_log_group_info = true
  log_format             = "Others"
  log_stream_prefix      = []

  // Auto Enable
  auto_enable_logs_subscription = "Both"
  auto_enable_logs_subscription_options = {
    filter = "lambda"
  }
}