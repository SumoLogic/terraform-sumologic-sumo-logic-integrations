# Outputs s3 logging
output "s3_logging_auto_enable_module" {
  value       = module.s3_logging_auto_enable_module
  description = "All outputs related to Auto Enable."
  sensitive   = true
}