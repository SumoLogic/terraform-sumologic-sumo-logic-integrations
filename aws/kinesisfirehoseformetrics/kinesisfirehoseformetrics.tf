# *************** Steps are as Below to create Sumo Logic CloudWatch Metrics source *************** #
# 1. Create AWS S3 Bucket and use an existing bucket as provided in the inputs.
# 2. Create Log Groups and Log Streams to attach to the kinesis firehose delivery stream.
# 3. Create IAM roles and IAM policies to attach to Kinesis Firehose and metric stream.
# 4. Create a Kinesis Firehose delivery stream.
# 5. Create a Metric stream 

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
  name              = "/aws/kinesisfirehose/kinesis-metrics-log-group-${random_string.aws_random.id}"
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
    KINESIS_FIREHOSE_ARN  = aws_kinesis_firehose_delivery_stream.metrics_delivery_stream.arn
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

resource "aws_iam_role" "metrics_role" {
  name               = "SumoLogic-Firehose-Metrics-${random_string.aws_random.id}"
  assume_role_policy = templatefile("${path.module}/templates/metrics_assume_role.tmpl", {})
}

resource "aws_iam_policy" "metrics_policy" {
  policy = templatefile("${path.module}/templates/metrics_policy.tmpl", {
    ARN         = local.arn_map[local.aws_region]
    AWS_REGION  = local.aws_region
    AWS_ACCOUNT = local.aws_account_id
    ROLE_NAME   = aws_iam_role.metrics_role.name
  })
}

resource "aws_iam_role_policy_attachment" "metrics_policy_attach" {
  policy_arn = aws_iam_policy.metrics_policy.arn
  role       = aws_iam_role.metrics_role.name
}

resource "aws_kinesis_firehose_delivery_stream" "metrics_delivery_stream" {
  name        = "Kinesis-Metrics-${random_string.aws_random.id}"
  destination = "http_endpoint"

  http_endpoint_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    url                = sumologic_kinesis_metrics_source.source.url
    name               = "sumologic-metrics-endpoint-${random_string.aws_random.id}"
    buffering_size     = 1
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
    //error_output_prefix = "SumoLogic-Kinesis-Failed-Metrics/"
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.log_group.name
      log_stream_name = aws_cloudwatch_log_stream.s3_log_stream.name
    }
  }
}

resource "aws_cloudwatch_metric_stream" "metric_stream" {
  name          = "sumologic-metric-stream-${random_string.aws_random.id}"
  role_arn      = aws_iam_role.metrics_role.arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.metrics_delivery_stream.arn
  output_format = "opentelemetry0.7"
  dynamic "include_filter" {
    for_each = var.source_details.limit_to_namespaces
    content {
      namespace = include_filter.value
    }
  }
}

resource "aws_iam_role" "source_iam_role" {
  for_each = toset(var.source_details.iam_details.create_iam_role ? ["source_iam_role"] : [])

  name = "SumoLogic-Kinesis-firehose-Metrics-Module-${random_string.aws_random.id}"
  path = "/"

  assume_role_policy = templatefile("${path.module}/templates/sumologic_assume_role.tmpl", {
    SUMO_LOGIC_ACCOUNT_ID = var.source_details.sumo_account_id,
    ENVIRONMENT           = data.sumologic_caller_identity.current.environment,
    SUMO_LOGIC_ORG_ID     = var.sumologic_organization_id,
    ARN                   = local.arn_map[local.aws_region]
  })

  managed_policy_arns = [aws_iam_policy.iam_policy["iam_policy"].arn]
}

resource "aws_iam_policy" "iam_policy" {
  for_each = toset(var.source_details.iam_details.create_iam_role ? ["iam_policy"] : [])

  name   = "SumoLogicCloudWatchMetricsSource-${random_string.aws_random.id}"
  policy = templatefile("${path.module}/templates/sumologic_source_policy.tmpl", {})
}

resource "sumologic_collector" "collector" {
  for_each    = toset(var.create_collector ? ["collector"] : [])
  name        = local.collector_name
  description = var.collector_details.description
  fields      = var.collector_details.fields
  timezone    = "UTC"
}

resource "time_sleep" "wait_for_seconds" {
  create_duration = "${var.wait_for_seconds}s"
}

resource "sumologic_kinesis_metrics_source" "source" {
  depends_on = [
    time_sleep.wait_for_seconds
  ]
  category     = var.source_details.source_category
  collector_id = var.create_collector ? sumologic_collector.collector["collector"].id : var.source_details.collector_id
  content_type = "KinesisMetric"
  description  = var.source_details.description
  fields       = var.source_details.fields
  name         = var.source_details.source_name

  authentication {
    type     = "AWSRoleBasedAuthentication"
    role_arn = var.source_details.iam_details.create_iam_role ? aws_iam_role.source_iam_role["source_iam_role"].arn : var.source_details.iam_details.iam_role_arn
  }

  path {
    type = "KinesisMetricPath"
  }
}