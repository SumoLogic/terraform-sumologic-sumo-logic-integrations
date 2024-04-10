locals {
  # AWS account details
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  # S3 bucket inputs
  bucket_name          = "aws-observability-random-${random_string.aws_random.id}"
  path_expression      = "AWSLogs/${local.aws_account_id}/clb/${local.aws_region}/*"
}