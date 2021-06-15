locals {

  aws_account_id = data.aws_caller_identity.current.account_id

  aws_region = data.aws_region.current.id

  # ARNs map for gov and non-gov regions
  arn_map = {
    "us-east-1"      = "aws",
    "us-east-2"      = "aws",
    "us-west-1"      = "aws",
    "us-west-2"      = "aws",
    "af-south-1"     = "aws",
    "ca-central-1"   = "aws",
    "eu-central-1"   = "aws",
    "eu-west-1"      = "aws",
    "eu-west-2"      = "aws",
    "eu-south-1"     = "aws",
    "eu-west-3"      = "aws",
    "eu-north-1"     = "aws",
    "ap-east-1"      = "aws",
    "ap-northeast-1" = "aws",
    "ap-northeast-2" = "aws",
    "ap-northeast-3" = "aws",
    "ap-southeast-1" = "aws",
    "ap-southeast-2" = "aws",
    "ap-south-1"     = "aws",
    "me-south-1"     = "aws",
    "sa-east-1"      = "aws",
    "us-gov-west-1"  = "aws-us-gov",
    "us-gov-east-1"  = "aws-us-gov",
    "cn-north-1"     = "aws",
    "cn-northwest-1" = "aws"
  }

  # create bucket if flag is set to true.
  create_bucket = var.create_bucket

  # bucket name should be dependent of the default value or provided one.
  bucket_name = local.create_bucket && var.bucket_details.bucket_name == "sumologic-kinesis-firehose-logs-accountid-region" ? "sumologic-kinesis-firehose-logs-${local.aws_account_id}-${local.aws_region}" : var.bucket_details.bucket_name

  # Get the default collector name if no collector name is provided.
  collector_name = var.collector_details.collector_name == "SumoLogic Kinesis Firehose for Logs Collector <AWS Account Id>" ? "SumoLogic Kinesis Firehose for Logs Collector ${local.aws_account_id}" : var.collector_details.collector_name

  # Auto enable should be called if input is anything other than None.
  auto_enable_logs_subscription = var.auto_enable_logs_subscription != "None" ? true : false

  # Existing
  auto_enable_existing = var.auto_enable_logs_subscription == "Existing" || var.auto_enable_logs_subscription == "Both" ? true : false
}