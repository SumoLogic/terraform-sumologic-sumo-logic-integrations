# *************** Steps are as Below to create Sumo Logic Kinesis Firehose for Logs source *************** #
# 1. Create AWS S3 Bucket and use an existing bucket as provided in the inputs.
# 2. Create Log Groups and Log Streams to attach to the kinesis firehose delivery stream.
# 3. Create IAM roles and IAM policies to attach to Kinesis Firehose and delivery stream.
# 4. Create a Kinesis Firehose delivery stream.
# 5. Create subscription for log group.

resource "random_string" "aws_random" {
  length  = 10
  special = false
  upper   = false
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "SumoCWLogGroup-${random_string.aws_random.id}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_log_subscription_filter" {
  destination_arn = aws_lambda_function.logs_lambda_function.arn
  filter_pattern  = ""
  log_group_name  = aws_cloudwatch_log_group.cloudwatch_log_group.name
  name            = "SumoCWLogSubscriptionFilter"
}

resource "aws_lambda_permission" "logs_lambda_invoke_permission" {
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.logs_lambda_function.function_name
  principal      = "logs.${local.aws_region}.amazonaws.com"
  source_account = local.aws_account_id
}

resource "aws_sqs_queue" "sqs_queue" {
  name = "SumoCWDeadLetterQueue-${random_string.aws_random.id}"
}

resource "aws_iam_role" "lambda_iam_role" {
  name = "SumoCWLambdaExecutionRole-${random_string.aws_random.id}"
  path = "/"

  assume_role_policy = templatefile("${path.module}/templates/logs_assume_role.tmpl", {})
}

resource "aws_iam_policy" "lambda_sqs_policy" {
  name = "SQSCreateLogs-${random_string.aws_random.id}"
  policy = templatefile("${path.module}/templates/lambda_sqs.tmpl", {
    DEAD_LETTER_QUEUE_ARN = aws_sqs_queue.sqs_queue.arn
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}

resource "aws_iam_policy" "create_logs_policy" {
  name = "CloudWatchCreateLogs-${random_string.aws_random.id}"
  policy = templatefile("${path.module}/templates/lambda_logs.tmpl", {
    LOG_GROUP_ARN = aws_cloudwatch_log_group.cloudwatch_log_group.arn
  })
}

resource "aws_iam_role_policy_attachment" "create_logs_policy_attachment" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.create_logs_policy.arn
}

resource "aws_iam_policy" "invoke_lambda_policy" {
  name = "InvokeLambda-${random_string.aws_random.id}"
  policy = templatefile("${path.module}/templates/invoke_lambda.tmpl", {
    LAMBDA_ARN = aws_lambda_function.process_dead_letter_queue_lambda.arn
  })
}

resource "aws_iam_role_policy_attachment" "invoke_lambda_policy_attachment" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.invoke_lambda_policy.arn
}

resource "aws_lambda_function" "logs_lambda_function" {
  function_name = "SumoCWLogsLambda-${random_string.aws_random.id}"
  handler       = "cloudwatchlogs_lambda.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_iam_role.arn
  s3_bucket     = "appdevzipfiles-${local.aws_region}"
  s3_key        = "cloudwatchLogsDLQ/v1.2.0/cloudwatchlogs-with-dlq.zip"
  timeout       = 300
  memory_size   = 128
  dead_letter_config {
    target_arn = aws_sqs_queue.sqs_queue.arn
  }

  environment {
    variables = {
      "SUMO_ENDPOINT"     = sumologic_http_source.source.url,
      "LOG_FORMAT"        = var.log_format,
      "INCLUDE_LOG_INFO"  = var.include_log_group_info,
      "LOG_STREAM_PREFIX" = join(",", var.log_stream_prefix)
    }
  }
}

resource "aws_lambda_function" "process_dead_letter_queue_lambda" {
  function_name = "SumoCWProcessDLQLambda-${random_string.aws_random.id}"
  handler       = "DLQProcessor.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_iam_role.arn
  s3_bucket     = "appdevzipfiles-${local.aws_region}"
  s3_key        = "cloudwatchLogsDLQ/v1.2.0/cloudwatchlogs-with-dlq.zip"
  timeout       = 300
  memory_size   = 128
  dead_letter_config {
    target_arn = aws_sqs_queue.sqs_queue.arn
  }

  environment {
    variables = {
      "SUMO_ENDPOINT"     = sumologic_http_source.source.url,
      "LOG_FORMAT"        = var.log_format,
      "INCLUDE_LOG_INFO"  = var.include_log_group_info,
      "LOG_STREAM_PREFIX" = join(",", var.log_stream_prefix),
      "TASK_QUEUE_URL"    = aws_sqs_queue.sqs_queue.arn,
      "NUM_OF_WORKERS"    = var.workers
    }
  }
}

resource "aws_lambda_permission" "process_dead_letter_queue_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_dead_letter_queue_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.process_dead_letter_queue_event_rule.arn
}

resource "aws_cloudwatch_event_rule" "process_dead_letter_queue_event_rule" {
  description         = "Events rule for Cron"
  schedule_expression = "rate(5 minutes)"
  state          = "ENABLED"
}

resource "aws_cloudwatch_event_target" "process_dead_letter_queue_event_rule_target" {
  arn       = aws_lambda_function.process_dead_letter_queue_lambda.arn
  rule      = aws_cloudwatch_event_rule.process_dead_letter_queue_event_rule.name
  target_id = "TargetFunctionV1"
}

resource "aws_sns_topic" "sns_topic" {
  name = "SumoCWEmailSNSTopic-${random_string.aws_random.id}"
}

resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  endpoint  = var.email_id
  protocol  = "email"
  topic_arn = aws_sns_topic.sns_topic.arn
}

resource "aws_cloudwatch_metric_alarm" "metric_alarm" {
  alarm_actions       = [aws_sns_topic.sns_topic.arn]
  alarm_description   = "Notify via email if number of messages in DeadLetterQueue exceeds threshold"
  alarm_name          = "SumoCWSpilloverAlarm-${random_string.aws_random.id}"
  comparison_operator = "GreaterThanThreshold"
  dimensions          = { "QueueName" = aws_sqs_queue.sqs_queue.name }
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 3600
  statistic           = "Sum"
  threshold           = 100000
}

resource "sumologic_collector" "collector" {
  for_each    = toset(var.create_collector ? ["collector"] : [])
  name        = local.collector_name
  description = var.collector_details.description
  fields      = var.collector_details.fields
  timezone    = "UTC"
}

resource "sumologic_http_source" "source" {
  name         = var.source_details.source_name
  description  = var.source_details.description
  category     = var.source_details.source_category
  collector_id = var.create_collector ? sumologic_collector.collector["collector"].id : var.source_details.collector_id
  fields       = var.source_details.fields
}

# Reason to use the SAM app, is to have single source of truth for Auto Subscribe functionality.
resource "aws_serverlessapplicationrepository_cloudformation_stack" "auto_enable_logs_subscription" {
  for_each = toset(local.auto_enable_logs_subscription ? ["auto_enable_logs_subscription"] : [])

  name             = "Auto-Enable-Logs-Subscription-${random_string.aws_random.id}"
  application_id   = "arn:aws:serverlessrepo:us-east-1:956882708938:applications/sumologic-loggroup-connector"
  semantic_version = var.app_semantic_version
  capabilities     = data.aws_serverlessapplicationrepository_application.app.required_capabilities
  parameters = {
    DestinationArnType  = "Lambda"
    DestinationArnValue = aws_lambda_function.logs_lambda_function.arn
    LogGroupPattern     = var.auto_enable_logs_subscription_options.filter
    LogGroupTags        = var.auto_enable_logs_subscription_options.tags_filter
    UseExistingLogs     = local.auto_enable_existing
  }
}