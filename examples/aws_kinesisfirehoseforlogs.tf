module "aws_kinesis_firehose_for_metrics" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/kinesisfirehoseforlogs"

  create_bucket = true
  bucket_details = {
    bucket_name          = "kinesis-firehose-tst-13adad"
    force_destroy_bucket = true
  }

  create_collector = true
  collector_details = {
    "collector_name" = "Test Kinesis Firehose for Logs Collector",
    "description"    = "This is a new description.",
    "fields" = {
      "TestCollector" = "MyValue"
    }
  }

  source_details = {
    "source_name"     = "My Kinesis Firehose for Logs Source",
    "source_category" = "Labs/test/logs",
    "description"     = "This source is created.",
    "fields" = {
      "TestCollector" = "MyValue"
    },
    "collector_id" = "",
  }

  auto_enable_logs_subscription = "Both"
  auto_enable_logs_subscription_options = {
    filter = "lambda"
  }
}