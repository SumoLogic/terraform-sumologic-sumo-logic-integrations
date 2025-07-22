module "cloudwatch_logs_lambda_log_forwarder_module" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/cloudwatchlogsforwarder"

  create_collector = true
  aws_resource_tags = local.aws_resource_tags

  # Lambda Log Forwarder configurations
  email_id               = "test@gmail.com"
  log_format             = "Others"
  log_stream_prefix      = []
  include_log_group_info = true
  workers                = 4

  source_details = {
    source_name     = "CloudWatch Logs (Region)"
    source_category = "Labs/aws/cloudwatch"
    description     = "Provide details for the Sumo Logic HTTP source. If not provided, then defaults will be used."
    collector_id    = module.cloudwatch_logs_lambda_log_forwarder_module.sumologic_collector.collector.id
    fields          = local.cloudwatch_logs_fields
  }

  auto_enable_logs_subscription = "Both"
  app_semantic_version = "1.0.14"
  auto_enable_logs_subscription_options = {
    filter = "lambda|rds"
    tags_filter = ""
  }
}