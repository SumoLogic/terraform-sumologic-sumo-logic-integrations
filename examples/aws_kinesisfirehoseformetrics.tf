module "kinesisfirehoseformetrics" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/kinesisfirehoseformetrics"

  sumologic_organization_id = "0000000000123456"
  create_bucket             = true
  bucket_details = {
    bucket_name          = "sumologic-kinesis-firehose-ashdjas"
    force_destroy_bucket = true
  }

  create_collector = true
  collector_details = {
    collector_name = "SumoLogic Kinesis Firehose for Metrics Collector"
    description    = "This collector is created using Sumo Logic terraform AWS Kinesis Firehose for metrics module to collect AWS cloudwatch metrics."
    fields         = {}
  }

  source_details = {
    source_name         = "Kinesis Firehose for Metrics Source"
    source_category     = "Labs/aws/cloudwatch/metrics"
    description         = "This source is created using Sumo Logic terraform AWS Kinesis Firehose for metrics module to collect AWS Cloudwatch metrics."
    collector_id        = ""
    limit_to_namespaces = ["AWS/SNS", "AWS/SQS"]
    sumo_account_id     = 926226587429
    fields              = {}
    "iam_details" = {
      "create_iam_role" = true,
      "iam_role_arn"    = ""
    }
  }
}