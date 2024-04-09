locals {

    # AWS account details
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  # Sumo account Details
  sumologic_organization_id = "0000000000285A74"
  sumologic_existing_collector_id = 254493957
  sumologic_environment = "us1"

  # Cloud Watch Log details
  cloudwatch_logs_source_details = {
    source_name     = "CloudWatch Logs (Region)"
    source_category = "Labs/aws/cloudwatch"
    description     = "Provide details for the Sumo Logic HTTP source. If not provided, then defaults will be used."
    fields          = {}
    bucket_details  = {
      create_bucket        = true
      bucket_name          = "aws-observability-${local.sumologic_existing_collector_id}"
      force_destroy_bucket = true
    }
    lambda_log_forwarder_config = {
      email_id               = "test@gmail.com"
      workers                = 4
      log_format             = "Others"
      include_log_group_info = true
      log_stream_prefix      = []
    }
  }
  cloudwatch_logs_fields      = { account = local.aws_account_id }
  auto_enable_logs_subscription = "Both"
  auto_enable_logs_subscription_options = {
    filter = "lambda|rds"
  }
}