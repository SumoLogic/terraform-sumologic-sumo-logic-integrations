output "aws_s3_bucket" {
  value       = local.create_bucket ? aws_s3_bucket.s3_bucket : {}
  description = "AWS S3 Bucket name created to Store the Failed data."
}

output "aws_cloudwatch_log_group" {
  value       = aws_cloudwatch_log_group.log_group
  description = "AWS Log group created to attach to delivery stream."
}

output "aws_cloudwatch_log_stream" {
  value       = toset([aws_cloudwatch_log_stream.http_log_stream, aws_cloudwatch_log_stream.s3_log_stream])
  description = "AWS Log stream created to attach to log group."
}

output "aws_iam_role" {
  value       = toset([aws_iam_role.logs_role, aws_iam_role.firehose_role])
  description = "AWS IAM role with permission to setup kinesis firehose logs."
}

output "sumologic_collector" {
  value       = var.create_collector ? sumologic_collector.collector : {}
  description = "Sumo Logic hosted collector."
}

output "sumologic_source" {
  value       = sumologic_http_source.source
  description = "Sumo Logic AWS ELB source."
}

output "aws_kinesis_firehose_delivery_stream" {
  value       = aws_kinesis_firehose_delivery_stream.logs_delivery_stream
  description = "AWS Kinesis firehose delivery stream to send logs to Sumo Logic."
}

output "aws_serverlessapplicationrepository_cloudformation_stack" {
  value       = aws_serverlessapplicationrepository_cloudformation_stack.auto_enable_logs_subscription
  description = "AWS CloudFormation stack for Auto Enable logs subscription."
}