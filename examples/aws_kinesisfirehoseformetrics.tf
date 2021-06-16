module "kinesisfirehoseformetrics" {
  source = "../aws/kinesisfirehoseformetrics"

  sumologic_organization_id = "00000000004F8319"
  create_bucket             = true
  bucket_details = {
    bucket_name          = "sumologic-kinesis-firehose-668508221233-us-east-1"
    force_destroy_bucket = true
  }

  create_collector = true
  collector_details = {
    collector_name = "SumoLogic Kinesis Firehose for Metrics Collector 668508221233"
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
    iam_role_arn        = ""
  }
}