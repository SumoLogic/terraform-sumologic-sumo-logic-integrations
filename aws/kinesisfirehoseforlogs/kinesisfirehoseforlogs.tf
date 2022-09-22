# *************** Steps are as Below to create Sumo Logic Kinesis Firehose for Logs source *************** #
# 1. Create AWS S3 Bucket and use an existing bucket as provided in the inputs.
# 2. Create Log Groups and Log Streams to attach to the kinesis firehose delivery stream.
# 3. Create IAM roles and IAM policies to attach to Kinesis Firehose and delivery stream.
# 4. Create a Kinesis Firehose delivery stream.
# 5. Create subscription for log group.

resource "random_string" "aws_random" {
  length  = 10
  special = false
  upper   = false
}

resource "aws_s3_bucket" "s3_bucket" {
  for_each = toset(local.create_bucket ? ["s3_bucket"] : [])

  bucket        = local.bucket_name
  force_destroy = var.bucket_details.force_destroy_bucket
  acl           = "private"
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_access_block" {
  for_each = toset(local.create_bucket ? ["s3_bucket_access_block"] : [])

  bucket                  = aws_s3_bucket.s3_bucket["s3_bucket"].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/kinesisfirehose/kinesis-logs-log-group-${random_string.aws_random.id}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "s3_log_stream" {
  log_group_name = aws_cloudwatch_log_group.log_group.name
  name           = "S3Delivery"
}

resource "aws_cloudwatch_log_stream" "http_log_stream" {
  log_group_name = aws_cloudwatch_log_group.log_group.name
  name           = "HttpEndpointDelivery"
}

resource "aws_iam_role" "firehose_role" {
  name = "SumoLogic-Firehose-${random_string.aws_random.id}"
  assume_role_policy = templatefile("${path.module}/templates/firehose_assume_role.tmpl", {
    AWS_ACCOUNT_ID = local.aws_account_id,
  })
}

resource "aws_iam_policy" "firehose_s3_upload_policy" {
  policy = templatefile("${path.module}/templates/firehose_s3_upload_policy.tmpl", {
    BUCKET_NAME = local.bucket_name
    ARN         = local.arn_map[local.aws_region]
  })
}

resource "aws_iam_policy" "firehose_delivery_policy" {
  policy = templatefile("${path.module}/templates/firehose_delivery_policy.tmpl", {
    KINESIS_LOG_GROUP_ARN = aws_cloudwatch_log_group.log_group.arn
    KINESIS_FIREHOSE_ARN  = aws_kinesis_firehose_delivery_stream.logs_delivery_stream.arn
  })
}

resource "aws_iam_role_policy_attachment" "firehose_policy_attach" {
  policy_arn = aws_iam_policy.firehose_delivery_policy.arn
  role       = aws_iam_role.firehose_role.name
}

resource "aws_iam_role_policy_attachment" "firehose_s3_policy_attach" {
  policy_arn = aws_iam_policy.firehose_s3_upload_policy.arn
  role       = aws_iam_role.firehose_role.name
}

resource "aws_iam_role" "logs_role" {
  name = "SumoLogic-Firehose-Logs-${random_string.aws_random.id}"
  assume_role_policy = templatefile("${path.module}/templates/logs_assume_role.tmpl", {
    AWS_REGION = local.aws_region
  })
}

resource "aws_iam_policy" "logs_policy" {
  policy = templatefile("${path.module}/templates/logs_policy.tmpl", {
    ARN         = local.arn_map[local.aws_region]
    AWS_REGION  = local.aws_region
    AWS_ACCOUNT = local.aws_account_id
    ROLE_NAME   = aws_iam_role.logs_role.name
  })
}

resource "aws_iam_role_policy_attachment" "logs_policy_attach" {
  policy_arn = aws_iam_policy.logs_policy.arn
  role       = aws_iam_role.logs_role.name
}

resource "aws_kinesis_firehose_delivery_stream" "logs_delivery_stream" {
  name        = "Kinesis-Logs-${random_string.aws_random.id}"
  destination = "http_endpoint"

  http_endpoint_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    url                = sumologic_http_source.source.url
    name               = "sumologic-logs-endpoint-${random_string.aws_random.id}"
    buffering_size     = 4
    buffering_interval = 60
    retry_duration     = 60
    s3_backup_mode     = "FailedDataOnly"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.log_group.name
      log_stream_name = aws_cloudwatch_log_stream.http_log_stream.name
    }

    request_configuration {
      content_encoding = "GZIP"
    }
  }

  s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = "arn:${local.arn_map[local.aws_region]}:s3:::${local.bucket_name}"
    compression_format = "UNCOMPRESSED"
    //error_output_prefix = "SumoLogic-Kinesis-Failed-Logs/"
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.log_group.name
      log_stream_name = aws_cloudwatch_log_stream.s3_log_stream.name
    }
  }
}

resource "aws_cloudwatch_log_subscription_filter" "delivery_stream_subscription" {
  name            = "sumologic_delivery_stream"
  role_arn        = aws_iam_role.logs_role.arn
  log_group_name  = aws_cloudwatch_log_group.log_group.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.logs_delivery_stream.arn
}

resource "sumologic_collector" "collector" {
  for_each    = toset(var.create_collector ? ["collector"] : [])
  name        = local.collector_name
  description = var.collector_details.description
  fields      = var.collector_details.fields
  timezone    = "UTC"
}

resource "sumologic_http_source" "source" {
  category     = var.source_details.source_category
  collector_id = var.create_collector ? sumologic_collector.collector["collector"].id : var.source_details.collector_id
  content_type = "KinesisLog"
  description  = var.source_details.description
  fields       = var.source_details.fields
  name         = var.source_details.source_name
}

# Reason to use the SAM app, is to have single source of truth for Auto Subscribe functionality.
resource "aws_serverlessapplicationrepository_cloudformation_stack" "auto_enable_logs_subscription" {
  for_each = toset(local.auto_enable_logs_subscription ? ["auto_enable_logs_subscription"] : [])

  name             = "Auto-Enable-Logs-Subscription-${random_string.aws_random.id}"
  application_id   = "arn:aws:serverlessrepo:us-east-1:956882708938:applications/sumologic-loggroup-connector"
  semantic_version = "1.0.6"
  capabilities     = data.aws_serverlessapplicationrepository_application.app.required_capabilities
  parameters = {
    DestinationArnType  = "Kinesis"
    DestinationArnValue = aws_kinesis_firehose_delivery_stream.logs_delivery_stream.arn
    LogGroupPattern     = var.auto_enable_logs_subscription_options.filter
    UseExistingLogs     = local.auto_enable_existing
    RoleArn             = aws_iam_role.logs_role.arn
  }
}