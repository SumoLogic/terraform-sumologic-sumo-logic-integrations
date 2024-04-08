module "kinesis_firehose_for_logs_module" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/kinesisfirehoseforlogs"

  create_collector = true

  source_details = {
    source_name     = "<Source-Name>"
    source_category = "<Source-Category>"
    description     = "<Source-Description>"
    collector_id    = null
    fields          = {}
  }

  create_bucket = true
  bucket_details = {
    bucket_name          = "<AWS-S3-bucket>"
    force_destroy_bucket = false
  }

  auto_enable_logs_subscription = "Both"
  app_semantic_version = "1.0.9"
  auto_enable_logs_subscription_options = {
    filter = "lambda|rds"
  }
}