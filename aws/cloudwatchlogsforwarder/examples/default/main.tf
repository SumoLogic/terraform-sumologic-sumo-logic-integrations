

module "cloudwatch_logs_lambda_log_forwarder_module" {
  source = "../../../cloudwatchlogsforwarder"

  create_collector = false

  # Lambda Log Forwarder configurations
  email_id               = local.cloudwatch_logs_source_details.lambda_log_forwarder_config.email_id
  log_format             = local.cloudwatch_logs_source_details.lambda_log_forwarder_config.log_format
  log_stream_prefix      = local.cloudwatch_logs_source_details.lambda_log_forwarder_config.log_stream_prefix
  include_log_group_info = local.cloudwatch_logs_source_details.lambda_log_forwarder_config.include_log_group_info
  workers                = local.cloudwatch_logs_source_details.lambda_log_forwarder_config.workers

  source_details = {
    source_name     = local.cloudwatch_logs_source_details.source_name
    source_category = local.cloudwatch_logs_source_details.source_category
    description     = local.cloudwatch_logs_source_details.description
    collector_id    = local.sumologic_existing_collector_id
    fields          = local.cloudwatch_logs_fields
  }

  auto_enable_logs_subscription = local.auto_enable_logs_subscription
  app_semantic_version = "1.0.9"
  auto_enable_logs_subscription_options = {
    filter = local.auto_enable_logs_subscription_options.filter
  }
}


