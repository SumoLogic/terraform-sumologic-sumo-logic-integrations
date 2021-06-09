output "sumologic_field" {
  value       = sumologic_field.SumoLogicFields
  description = "This output contains all the fields."
}

output "sumologic_field_extraction_rule" {
  value       = sumologic_field_extraction_rule.SumoLogicFieldExtractionRules
  description = "This output contains all the Field Extraction rules."
}

output "sumologic_content" {
  value       = sumologic_content.SumoLogicApps
  description = "This output contains all the Apps."
}

output "sumologic_metric_rules" {
  value       = null_resource.MetricRules
  description = "This output contains all the metric rules."
}