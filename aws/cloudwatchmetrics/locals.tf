locals {

  aws_account_id = data.aws_caller_identity.current.account_id

  aws_region = data.aws_region.current.id

  # Get the default collector name if no collector name is provided.
  collector_name = var.collector_details.collector_name == "SumoLogic CloudWatch Metrics Collector <AWS Account Id>" ? "SumoLogic CloudWatch Metrics Collector ${local.aws_account_id}" : var.collector_details.collector_name

  # Create IAM role condition if no IAM ROLE ARN is provided.
  create_iam_role = var.source_details.iam_role_arn != "" ? false : true
}