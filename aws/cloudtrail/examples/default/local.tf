locals {
  # Wait time
  wait_for_seconds = 180

  # AWS account details
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name
  create_iam_role = true
  # common_bucket_name = "aws-observability-${random_string.aws_random.id}"

  # Sumo AWS account ID
  sumo_account_id = "926226587429"
  # Sumo account Details
  sumologic_organization_id = "0000000000285A74"
  sumologic_existing_collector_id = 170655886
  sumologic_environment = "us1"

  # CloudTrail Source updated Details
  create_collector = true
  create_trail = true
  create_sns_topic = true
  cloudtrail_source_details = {
    source_name     = "CloudTrail Logs (Region)"
    source_category = "aws/observability/cloudtrail/logs"
    description     = "This source is created using Sumo Logic terraform AWS Observability module to collect AWS cloudtrail logs."
    bucket_details  = {
      create_bucket        = true
      bucket_name          = "aws-observability-random-${local.sumologic_existing_collector_id}"
      path_expression      = "AWSLogs/${local.aws_account_id}/CloudTrail/${local.aws_region}/*"
      force_destroy_bucket = true
    }
  }
  cloudtrail_fields      = { account = local.aws_account_id }
  cloudtrail_source_bucket_name = "akhil_${local.aws_region}_${local.sumologic_organization_id}"
}