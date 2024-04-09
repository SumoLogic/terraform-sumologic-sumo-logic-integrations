locals {
  # AWS account details
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  # CloudTrail inputs
  bucket_name          = "aws-observability-random-${var.sumologic_collector_id}"
  path_expression      = "AWSLogs/${local.aws_account_id}/CloudTrail/${local.aws_region}/*"
  cloudtrail_fields      = { account = local.aws_account_id }
  cloudtrail_source_bucket_name = "akhil_${local.aws_region}_${var.sumologic_organization_id}"
}