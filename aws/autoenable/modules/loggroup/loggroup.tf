# Random string for naming
resource "random_string" "stack_suffix" {
  length  = 16
  special = false
  upper   = false
}

# IAM Role for SumoLogGroupLambdaConnector
resource "aws_iam_role" "sumo_log_group_lambda_connector" {
  name = "SumoLogGroupLambdaConnectorRole-${local.random_id_part}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.aws_resource_tags
}

resource "aws_iam_role_policy" "lambda_execution_policy" {
  name = "LambdaExecutionPolicy-${local.random_id_part}"
  role = aws_iam_role.sumo_log_group_lambda_connector.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadWriteFilterPolicy"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutSubscriptionFilter",
          "logs:ListTagsLogGroup"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:*"
        ]
      },
      {
        Sid    = "InvokePolicy"
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:lambda:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:function:*SumoLogGroupLambda*"
        ]
      }
    ]
  })
}

# Lambda Function - SumoLogGroupLambdaConnector
resource "aws_lambda_function" "sumo_log_group_lambda_connector" {
  function_name = "SumoLogGroupLambdaConnector-${local.random_id_part}"
  s3_bucket     = local.region_bucket_map[data.aws_region.current.id]
  s3_key        = "sumologic-aws-observability/functions/loggroup-lambda-connector/v1.0.16/loggroup-lambda-connector.zip"
  handler       = "loggroup-lambda-connector.handler"
  runtime       = "nodejs24.x"
  memory_size   = 128
  timeout       = 900
  role          = aws_iam_role.sumo_log_group_lambda_connector.arn

  environment {
    variables = {
      DESTINATION_ARN    = var.destination_arn_value
      LOG_GROUP_PATTERN  = var.log_group_pattern
      LOG_GROUP_TAGS     = var.log_group_tags
      ROLE_ARN           = var.role_arn
    }
  }

  tags = var.aws_resource_tags
}

# EventBridge Rule
resource "aws_cloudwatch_event_rule" "sumo_log_group_lambda_event_rule" {
  name        = "sumo-log-group-${local.random_id_part}"
  description = "Auto subscribe new CloudWatch log groups"

  event_pattern = jsonencode({
    source = ["aws.logs"]
    detail = {
      eventSource = ["logs.amazonaws.com"]
      eventName   = ["CreateLogGroup"]
    }
  })

  tags = var.aws_resource_tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.sumo_log_group_lambda_event_rule.name
  target_id = "Main"
  arn       = aws_lambda_function.sumo_log_group_lambda_connector.arn
}

# Lambda Permission for EventBridge
resource "aws_lambda_permission" "auto_subscribe_cw_log_group" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sumo_log_group_lambda_connector.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sumo_log_group_lambda_event_rule.arn
}

# Lambda Permission for CloudWatch Logs (conditional)
resource "aws_lambda_permission" "sumo_cw_lambda_invoke" {
  count = local.create_invoke_permission ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = var.destination_arn_value
  principal     = "logs.${data.aws_region.current.id}.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn    = "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:*:*"
}

# IAM Policy for Kinesis PassRole (conditional)
resource "aws_iam_role_policy" "kinesis_firehose_logs_policy" {
  count = local.create_pass_role ? 1 : 0

  name = "KinesisFirehoseLogsPolicy-${local.random_id_part}"
  role = aws_iam_role.sumo_log_group_lambda_connector.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = var.role_arn
      }
    ]
  })
}

# Resources for handling existing logs (conditional)
resource "aws_iam_role" "sumo_log_group_existing_lambda_connector" {
  count = local.invoke_existing ? 1 : 0
  name  = "SumoLogGroupExistingLambdaConnectorRole-${local.random_id_part}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = var.aws_resource_tags
}

resource "aws_iam_role_policy" "existing_lambda_invoke_policy" {
  count = local.invoke_existing ? 1 : 0
  name  = "InvokePolicy"
  role  = aws_iam_role.sumo_log_group_existing_lambda_connector[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadWriteFilterPolicy"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutSubscriptionFilter",
          "logs:ListTagsLogGroup"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:*"
        ]
      },
      {
        Sid    = "InvokePolicy"
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          aws_lambda_function.sumo_log_group_lambda_connector.arn
        ]
      }
    ]
  })
  depends_on = [
    aws_lambda_function.sumo_log_group_lambda_connector
  ]
}

data "archive_file" "existing_lambda_zip" {
  count       = local.invoke_existing ? 1 : 0
  type        = "zip"
  output_path = "${path.module}/existing_lambda_connector.zip"

  source {
    content = <<-EOF
      const { LambdaClient, InvokeCommand } = require("@aws-sdk/client-lambda");
      const lambda = new LambdaClient({ apiVersion: '2015-03-31' });
      exports.handler = async function (event, context) {
        const payload = {
            "existingLogs": "true",
            "token": ""
        };
        const responseData = {};
        let responseStatus = "FAILED";
        try {
          const invokeInput = new InvokeCommand({
            InvocationType: 'Event',
            FunctionName: process.env.FUNCTION_NAME,
            Payload: JSON.stringify(payload),
          });
          const response = await lambda.send(invokeInput);
          console.log('Successfully invoked lambda:', response);
          return {
                statusCode: 200,
                body: JSON.stringify({ message: 'Lambda invoked successfully' })
          };
        } catch (err) {
          responseData.Error = "Invoke call failed";
          console.log(responseData.Error + ":\n", err);
        }
      };
    EOF
    filename = "index.js"
  }
}

resource "aws_lambda_function" "sumo_log_group_existing_lambda_connector" {
  count = local.invoke_existing ? 1 : 0

  function_name = "SumoLogGroupExistingLambdaConnector-${local.random_id_part}"
  handler       = "index.handler"
  runtime       = "nodejs24.x"
  role          = aws_iam_role.sumo_log_group_existing_lambda_connector[0].arn

  # Use the archive_file data source
  filename         = data.archive_file.existing_lambda_zip[0].output_path
  source_code_hash = data.archive_file.existing_lambda_zip[0].output_base64sha256

  environment {
    variables = {
      FUNCTION_NAME = aws_lambda_function.sumo_log_group_lambda_connector.function_name
    }
  }

  depends_on = [
    aws_lambda_function.sumo_log_group_lambda_connector,
    data.archive_file.existing_lambda_zip,
  ]
}

# Wait for IAM policy propagation
resource "time_sleep" "wait_for_iam_propagation" {
  count = local.invoke_existing ? 1 : 0

  depends_on = [
    aws_lambda_function.sumo_log_group_existing_lambda_connector,
    aws_iam_role_policy.existing_lambda_invoke_policy
  ]

  create_duration = "5s"  # IAM can take 5-10 seconds to propagate
}

# Custom Resource to invoke existing logs lambda (if enabled)
resource "null_resource" "invoke_lambda_connector" {
  count = local.invoke_existing ? 1 : 0

  triggers = {
    destination_arn    = var.destination_arn_value
    log_group_pattern  = var.log_group_pattern
    role_arn          = var.role_arn
  }

  provisioner "local-exec" {
    command = <<-EOF
      aws lambda invoke \
        --function-name ${aws_lambda_function.sumo_log_group_existing_lambda_connector[0].function_name} \
        --invocation-type Event \
        --region ${data.aws_region.current.id} \
        /dev/null
    EOF
  }

  depends_on = [
    aws_lambda_function.sumo_log_group_existing_lambda_connector,
    time_sleep.wait_for_iam_propagation
  ]
}

