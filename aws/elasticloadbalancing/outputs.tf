output "random_string" {
  value       = random_string.aws_random
  description = "Random String value created."
}

output "aws_s3_bucket" {
  value       = var.source_details.bucket_details.create_bucket ? aws_s3_bucket.s3_bucket : {}
  description = "AWS S3 Bucket name created to Store the ELB logs."
}

output "aws_sns_topic" {
  value       = var.source_details.sns_topic_details.create_sns_topic ? aws_sns_topic.sns_topic : {}
  description = "AWS SNS topic attached to the AWS S3 bucket."
}

output "aws_s3_bucket_notification" {
  value       = var.source_details.sns_topic_details.create_sns_topic && var.source_details.bucket_details.create_bucket ? aws_s3_bucket_notification.bucket_notification : {}
  description = "AWS S3 Bucket Notification attached to the AWS S3 Bucket"
}

output "aws_iam_role" {
  value       = var.source_details.iam_details.create_iam_role ? aws_iam_role.source_iam_role : {}
  description = "AWS IAM role with permission to allow Sumo Logic to read logs from S3 Bucket."
}

output "sumologic_collector" {
  value       = var.create_collector ? sumologic_collector.collector : {}
  description = "Sumo Logic hosted collector."
}

output "sumologic_source" {
  value       = sumologic_elb_source.source
  description = "Sumo Logic AWS ELB source."
}

output "aws_sns_subscription" {
  value       = aws_sns_topic_subscription.subscription
  description = "AWS SNS subscription to Sumo Logic AWS ELB source."
}

output "aws_serverlessapplicationrepository_cloudformation_stack" {
  value       = local.auto_enable_access_logs ? aws_serverlessapplicationrepository_cloudformation_stack.auto_enable_access_logs : {}
  description = "AWS CloudFormation stack for ELB Auto Enable access logs."
}