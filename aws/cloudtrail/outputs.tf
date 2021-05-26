output "aws_s3_bucket" {
  value       = var.source_details.bucket_details.create_bucket ? aws_s3_bucket.s3_bucket : {}
  description = "AWS S3 Bucket name created to Store the CloudTrail logs."
}

output "aws_sns_topic" {
  value       = local.create_sns_topic ? aws_sns_topic.sns_topic : {}
  description = "AWS SNS topic attached to the AWS S3 bucket."
}

output "aws_cloudtrail" {
  value       = var.create_trail ? aws_cloudtrail.cloudtrail : {}
  description = "AWS Trail created to send CloudTrail logs to AWS S3 bucket."
}

output "aws_iam_role" {
  value       = local.create_iam_role ? aws_iam_role.source_iam_role : {}
  description = "AWS IAM role with permission to allow Sumo Logic to read logs from S3 Bucket."
}

output "sumologic_collector" {
  value       = var.create_collector ? sumologic_collector.hosted : {}
  description = "Sumo Logic hosted collector."
}

output "sumologic_source" {
  value       = sumologic_cloudtrail_source.source
  description = "Sumo Logic AWS CloudTrail source."
}

output "aws_sns_subscription" {
  value       = aws_sns_topic_subscription.subscription
  description = "AWS SNS subscription to Sumo Logic AWS CloudTrail source."
}