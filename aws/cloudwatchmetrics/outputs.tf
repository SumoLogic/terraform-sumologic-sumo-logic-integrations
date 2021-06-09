output "aws_iam_role" {
  value       = local.create_iam_role ? aws_iam_role.source_iam_role : {}
  description = "AWS IAM role with permission to allow Sumo Logic to read logs from S3 Bucket."
}

output "sumologic_collector" {
  value       = var.create_collector ? sumologic_collector.collector : {}
  description = "Sumo Logic hosted collector."
}

output "sumologic_source" {
  value       = sumologic_cloudwatch_source.cloudwatch_metrics_sources
  description = "Sumo Logic AWS Cloudwatch metrics source."
}