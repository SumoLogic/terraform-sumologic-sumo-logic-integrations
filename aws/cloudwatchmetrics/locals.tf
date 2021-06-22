locals {

  # Get the default collector name if no collector name is provided.
  collector_name = var.collector_details.collector_name == "SumoLogic CloudWatch Metrics Collector <Random ID>" ? "SumoLogic CloudWatch Metrics Collector ${random_string.aws_random.id}" : var.collector_details.collector_name

  # Create IAM role condition if no IAM ROLE ARN is provided.
  create_iam_role = var.source_details.iam_role_arn != "" ? false : true
}