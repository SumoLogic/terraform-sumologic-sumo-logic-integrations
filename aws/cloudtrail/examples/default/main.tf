
module "cloudtrail_module" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/cloudtrail"

  create_collector          = true
  create_trail              = true
  sumologic_organization_id = var.sumologic_organization_id
  wait_for_seconds          = 20

  source_details = {
    source_name     = "CloudTrail Logs (Region)"
    source_category = "aws/observability/cloudtrail/logs"
    description     = "This source is created using Sumo Logic terraform AWS Observability module to collect AWS cloudtrail logs."
    collector_id    = var.sumologic_collector_id
    bucket_details = {
      create_bucket        = true
      bucket_name          = local.bucket_name
      path_expression      = local.path_expression
      force_destroy_bucket = false
    }
    paused               = false
    scan_interval        = 60000
    sumo_account_id      = var.sumo_aws_account_id
    cutoff_relative_time = "-1d"
    fields               = local.cloudtrail_fields
    iam_details = {
      create_iam_role = true
      iam_role_arn    = null
    }
    sns_topic_details = {
      create_sns_topic = true
      sns_topic_arn = null
    }
  }
}