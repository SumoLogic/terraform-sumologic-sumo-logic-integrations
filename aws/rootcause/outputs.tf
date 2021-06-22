output "random_string" {
  value       = random_string.aws_random
  description = "Random String value created."
}

output "aws_iam_role" {
  value       = local.create_iam_role ? aws_iam_role.source_iam_role : {}
  description = "AWS IAM role with permission to allow Sumo Logic to read logs from S3 Bucket."
}

output "sumologic_collector" {
  value       = var.create_collector ? sumologic_collector.collector : {}
  description = "Sumo Logic hosted collector."
}

output "inventory_sumologic_source" {
  value       = local.create_inventory_source ? sumologic_aws_inventory_source.aws_inventory_source : {}
  description = "Sumo Logic AWS Inventory source."
}

output "xray_sumologic_source" {
  value       = local.create_xray_source ? sumologic_aws_xray_source.aws_xray_source : {}
  description = "Sumo Logic AWS XRAY source."
}