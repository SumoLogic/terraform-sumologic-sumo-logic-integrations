# Output for loggroup
output "sumo_log_group_lambda_connector_arn" {
  description = "The ARN of the SumoLogGroupLambdaConnector function"
  value       = aws_lambda_function.sumo_log_group_lambda_connector.arn
}