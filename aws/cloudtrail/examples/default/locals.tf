locals {
  # AWS account details
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.current.name

  # CloudTrail inputs
  bucket_name       = "aws-observability-random-${random_string.aws_random.id}"
  path_expression   = "AWSLogs/${local.aws_account_id}/CloudTrail/${local.aws_region}/*"
  cloudtrail_fields = { account = local.aws_account_id }

  # AWS resource tags
  aws_resource_tags = {
    Creator     = "SumoLogic"
    Environment = "Test"
  }
}