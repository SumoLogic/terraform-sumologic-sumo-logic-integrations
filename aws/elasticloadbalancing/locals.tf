locals {
 aws_region = data.aws_region.current.region

  # sumo aws account ids
  sumo_account_ids = {
    aws        = "926226587429"  # Commercial AWS account
    aws-us-gov = "926226587429"   # GovCloud account
    aws-cn     = "926226587429"   # China account
    aws-eusc   = "052162193518"   # EU Sovereign account
  }

  # Get the default collector name if no collector name is provided.
  collector_name = var.collector_details.collector_name == "SumoLogic Elb Collector <Random ID>" ? "SumoLogic Elb Collector ${random_string.aws_random.id}" : var.collector_details.collector_name

  # Get the default bucket name when no bucket is provided and create_bucket is true.
  bucket_name = var.source_details.bucket_details.create_bucket && var.source_details.bucket_details.bucket_name == "elb-logs-random-id" ? "elb-logs-${random_string.aws_random.id}" : var.source_details.bucket_details.bucket_name

  # Auto enable should be called if input is anything other than None.
  auto_enable_access_logs = var.auto_enable_access_logs != "None" ? true : false

  # If we create the bucket, then get the default PATH expression.
  logs_path_expression = var.source_details.bucket_details.create_bucket ? "*${var.auto_enable_access_logs_options.bucket_prefix}/AWSLogs/${local.aws_account_id}/elasticloadbalancing/${local.aws_region}/*" : var.source_details.bucket_details.path_expression

}