locals {

  aws_account_id = data.aws_caller_identity.current.account_id

  aws_region = data.aws_region.current.id

  # Get the default collector name if no collector name is provided.
  collector_name = var.collector_details.collector_name == "SumoLogic CloudTrail Collector <Random ID>" ? "SumoLogic CloudTrail Collector ${random_string.aws_random.id}" : var.collector_details.collector_name

  # Get the default cloudtrail name if default is provided.
  cloudtrail_name = var.cloudtrail_details.name == "SumoLogic-Terraform-CloudTrail-random-id" ? "SumoLogic-Terraform-CloudTrail-${random_string.aws_random.id}" : var.cloudtrail_details.name

  # Get the default bucket name when no bucket is provided and create_bucket is true.
  bucket_name = var.source_details.bucket_details.create_bucket && var.source_details.bucket_details.bucket_name == "cloudtrail-logs-random-id" ? "cloudtrail-logs-${random_string.aws_random.id}" : var.source_details.bucket_details.bucket_name

  # Create IAM role condition if no IAM ROLE ARN is provided.
  create_iam_role = var.source_details.iam_role_arn != "" ? false : true

  # Create SNS topic condition if no SNS topic arn is provided.
  create_sns_topic = var.source_details.sns_topic_arn != "" ? false : true

  # Trail should be created when we create the bucket. If we do not create the bucket, user should have capability to create and not create trail.
  create_trail = var.source_details.bucket_details.create_bucket ? true : var.create_trail

  # If we create the bucket, then get the default PATH expression.
  logs_path_expression = var.source_details.bucket_details.create_bucket ? "AWSLogs/${local.aws_account_id}/CloudTrail/${local.aws_region}/*" : var.source_details.bucket_details.path_expression
}