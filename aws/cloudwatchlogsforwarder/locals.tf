locals {

  aws_account_id = data.aws_caller_identity.current.account_id

  aws_region = data.aws_region.current.id

  # Get the default collector name if no collector name is provided.
  collector_name = var.collector_details.collector_name == "SumoLogic CloudWatch Logs Collector <Random ID>" ? "SumoLogic CloudWatch Logs Collector ${random_string.aws_random.id}" : var.collector_details.collector_name

  # Auto enable should be called if input is anything other than None.
  auto_enable_logs_subscription = var.auto_enable_logs_subscription != "None" ? true : false

  # Existing
  auto_enable_existing = var.auto_enable_logs_subscription == "Existing" || var.auto_enable_logs_subscription == "Both" ? true : false
}