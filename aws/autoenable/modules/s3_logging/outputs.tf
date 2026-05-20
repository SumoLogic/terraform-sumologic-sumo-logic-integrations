# Outputs s3 logging
output "enable_new_aws_resources_lambda_arn" {
  description = "Lambda Function ARN for New AWS Resources"
  value       = local.auto_enable_new ? aws_lambda_function.enable_new_aws_resources[0].arn : null
}

output "enable_existing_aws_resources_lambda_arn" {
  description = "Lambda Function ARN for Existing AWS Resources"
  value       = local.auto_enable_existing ? aws_lambda_function.enable_existing_aws_resources[0].arn : null
}
