locals {

  aws_account_id = data.aws_caller_identity.current.account_id

  aws_region = data.aws_region.current.id

  # create bucket if flag is set to true.
  create_bucket = var.create_bucket

  # bucket name should be dependent of the default value or provided one.
  bucket_name = local.create_bucket && var.bucket_details.bucket_name == "sumologic-kinesis-firehose-metrics-random-id" ? "sumologic-kinesis-firehose-metrics-${random_string.aws_random.id}" : var.bucket_details.bucket_name

  # Get the default collector name if no collector name is provided.
  collector_name = var.collector_details.collector_name == "SumoLogic Kinesis Firehose for Metrics Collector <Random ID>" ? "SumoLogic Kinesis Firehose for Metrics Collector ${random_string.aws_random.id}" : var.collector_details.collector_name
}