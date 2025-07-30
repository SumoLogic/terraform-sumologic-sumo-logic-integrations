output "random_string" {
  value       = random_string.aws_random
  description = "Random String value created."
}

output "aws_s3_bucket" {
  value       = local.create_bucket ? aws_s3_bucket.s3_bucket : {}
  description = "AWS S3 Bucket name created to Store the Failed data."
}

output "aws_cloudwatch_log_group" {
  value       = aws_cloudwatch_log_group.log_group
  description = "AWS Log group created to attach to delivery stream."
}

output "aws_cloudwatch_log_stream" {
  value       = tomap({ "http_log_stream" = aws_cloudwatch_log_stream.http_log_stream, "s3_log_stream" = aws_cloudwatch_log_stream.s3_log_stream })
  description = "AWS Log stream created to attach to log group."
}

output "source_aws_iam_role" {
  value       = var.source_details.iam_details.create_iam_role ? aws_iam_role.source_iam_role : {}
  description = "AWS IAM role with permission to setup Sumo Logic permissions."
}

output "aws_iam_role" {
  value       = tomap({ "metrics_role" = aws_iam_role.metrics_role, "firehose_role" = aws_iam_role.firehose_role })
  description = "AWS IAM role with permission to setup kinesis firehose metrics."
}

output "sumologic_collector" {
  value       = var.create_collector ? sumologic_collector.collector : {}
  description = "Sumo Logic hosted collector."
}

output "sumologic_source" {
  value       = sumologic_kinesis_metrics_source.source
  description = "Sumo Logic AWS Kinesis Firehose for Metrics source."
}

output "aws_kinesis_firehose_delivery_stream" {
  value       = aws_kinesis_firehose_delivery_stream.metrics_delivery_stream
  sensitive   = true
  description = "AWS Kinesis firehose delivery stream to send metrics to Sumo Logic."
}

output "aws_cloudwatch_metric_stream" {
  value       = aws_cloudwatch_metric_stream.metric_stream
  description = "CloudWatch metrics stream to send metrics."
}