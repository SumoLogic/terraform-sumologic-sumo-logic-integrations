resource "random_string" "aws_random" {
  length  = 10
  upper   = false
  special = false
}

module "kinesis_firehose_for_logs_module" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/kinesisfirehoseforlogs"

  create_collector = true

  source_details = {
    source_name     = "Cloud Watch Logs (Region)"
    source_category = "aws/observability/cloudwatch/logs"
    description     = "This source is created using Sumo Logic terraform AWS Observability module to collect AWS Cloud Watch logs."
    collector_id    = null
    fields          = {}
  }

  create_bucket = true
  bucket_details = {
    bucket_name          = local.bucket_name
    force_destroy_bucket = false
  }

  auto_enable_logs_subscription = "Both"
  app_semantic_version = "1.0.9"
  auto_enable_logs_subscription_options = {
    filter = "lambda|rds"
  }
}