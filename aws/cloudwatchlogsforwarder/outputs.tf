output "random_string" {
  value       = random_string.aws_random
  description = "Random String value created."
}

output "aws_sqs_queue" {
  value       = aws_sqs_queue.sqs_queue
  description = "AWS SQS queue to Store the Failed data."
}

output "aws_cloudwatch_log_group" {
  value       = aws_cloudwatch_log_group.cloudwatch_log_group
  description = "AWS Log group created to attach to the lambda function."
}

output "aws_iam_role" {
  value       = aws_iam_role.lambda_iam_role
  description = "AWS IAM role with permission to setup lambda."
}

output "aws_sns_topic" {
  value       = aws_sns_topic.sns_topic
  description = "AWS SNS topic"
}

output "aws_cloudwatch_metric_alarm" {
  value       = aws_cloudwatch_metric_alarm.metric_alarm
  description = "AWS CLoudWatch metric alarm."
}

output "aws_cw_lambda_function" {
  value       = aws_lambda_function.logs_lambda_function
  description = "AWS Lambda fucntion to send logs to Sumo Logic."
}

output "sumologic_collector" {
  value       = var.create_collector ? sumologic_collector.collector : {}
  description = "Sumo Logic hosted collector."
}

output "sumologic_source" {
  value       = sumologic_http_source.source
  description = "Sumo Logic HTTP source."
}

output "aws_serverlessapplicationrepository_cloudformation_stack" {
  value       = local.auto_enable_logs_subscription ? aws_serverlessapplicationrepository_cloudformation_stack.auto_enable_logs_subscription : {}
  description = "AWS CloudFormation stack for Auto Enable logs subscription."
}