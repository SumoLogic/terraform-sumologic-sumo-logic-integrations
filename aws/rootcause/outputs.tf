output "random_string" {
  value       = random_string.aws_random.id
  description = "Random String value created."
}

output "aws_iam_role" {
  value = var.iam_details.create_iam_role ? {
    for k, v in aws_iam_role.source_iam_role : k => {
      arn  = v.arn
      name = v.name
      id   = v.id
    }
  } : {}
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