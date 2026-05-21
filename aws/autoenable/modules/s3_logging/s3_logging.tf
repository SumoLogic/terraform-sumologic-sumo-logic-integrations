# *************** Steps are as Below to create Auto Enable AWS Logging *************** #
# 1. Create AWS IAM role with permissions to manage S3 bucket logging, VPC flow logs, and Load Balancer access logs.
# 2. Create AWS Lambda function for processing new AWS resources with environment variables for bucket configuration and filtering.
# 3. Create AWS CloudWatch Event Rules to trigger Lambda function based on the selected resource type (S3, VPC, ALB, or ELB).
# 4. Create AWS Lambda permissions to allow CloudWatch Events to invoke the Lambda function.
# 5. Create AWS CloudWatch Event Targets to link Event Rules with the Lambda function.
# 6. Create additional AWS Lambda function for processing existing AWS resources if auto_enable_resource_options includes "Existing" or "Both".
# 7. Invoke the existing resources Lambda function once to enable logging for pre-existing AWS resources based on the selected resource type and filter criteria.

# Random string for naming
resource "random_string" "stack_suffix" {
  length  = 16
  special = false
  upper   = false
}

# IAM Role for Lambda
resource "aws_iam_role" "sumo_lambda_role" {
  name = "SumoLambdaRole-${local.random_id_part}"

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

# IAM Policy for Lambda using template
resource "aws_iam_role_policy" "sumo_lambda_policy" {
  name = "AwsObservabilityLambdaExecutePolicies"
  role = aws_iam_role.sumo_lambda_role.id
  policy = templatefile("${path.module}/templates/sumo_lambda_auto_enable_policy.tmpl", {})
}

# Lambda Function for New AWS Resources
resource "aws_lambda_function" "enable_new_aws_resources" {
  count = local.auto_enable_new ? 1 : 0

  function_name = "EnableNewAWSResourcesLambda-${local.random_id_part}"
  role         = aws_iam_role.sumo_lambda_role.arn
  handler      = "awsresource.enable_s3_logs"
  runtime      = "python3.13"
  memory_size  = 128
  timeout      = 600
  description  = "Lambda Function for auto enable s3 logs for AWS Resources."

  s3_bucket = local.region_bucket_map[data.aws_region.current.id]
  s3_key    = "sumologic-aws-observability/functions/sumo-app-utils/v3.0.0/sumo-app-utils.zip"

  environment {
    variables = {
      BucketName   = var.bucket_name
      AccountID    = data.aws_caller_identity.current.account_id
      Filter       = var.filter_expression
      BucketPrefix = var.bucket_prefix
    }
  }

  tags = var.aws_resource_tags

  depends_on = [aws_iam_role_policy.sumo_lambda_policy]
}

# CloudWatch Event Rules and Permissions for S3
resource "aws_cloudwatch_event_rule" "auto_enable_s3_log_events" {
  count = local.enable_s3_log_events ? 1 : 0

  name        = "sumo-logic-s3-buckets-${local.random_id_part}"
  description = "Auto-Enable S3 logging for S3 Buckets with Lambda from events"
  state       = "ENABLED"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["s3.amazonaws.com"]
      eventName   = ["CreateBucket"]
    }
  })

  tags = var.aws_resource_tags
}

resource "aws_cloudwatch_event_target" "s3_lambda_target" {
  count = local.enable_s3_log_events ? 1 : 0

  rule      = aws_cloudwatch_event_rule.auto_enable_s3_log_events[0].name
  target_id = "Main"
  arn       = aws_lambda_function.enable_new_aws_resources[0].arn
}

resource "aws_lambda_permission" "s3_events_invoke_permission" {
  count = local.enable_s3_log_events ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.enable_new_aws_resources[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto_enable_s3_log_events[0].arn
}

# CloudWatch Event Rules and Permissions for VPC
resource "aws_cloudwatch_event_rule" "auto_enable_vpc_log_events" {
  count = local.enable_vpc_log_events ? 1 : 0

  name        = "sumo-logic-vpc-${local.random_id_part}"
  description = "Auto-Enable VPC Flow logs for VPCs with Lambda from events"
  state       = "ENABLED"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["ec2.amazonaws.com"]
      eventName   = ["CreateVpc"]
    }
  })

  tags = var.aws_resource_tags
}

resource "aws_cloudwatch_event_target" "vpc_lambda_target" {
  count = local.enable_vpc_log_events ? 1 : 0

  rule      = aws_cloudwatch_event_rule.auto_enable_vpc_log_events[0].name
  target_id = "Main"
  arn       = aws_lambda_function.enable_new_aws_resources[0].arn
}

resource "aws_lambda_permission" "vpc_events_invoke_permission" {
  count = local.enable_vpc_log_events ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.enable_new_aws_resources[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto_enable_vpc_log_events[0].arn
}

# CloudWatch Event Rules and Permissions for ALB
resource "aws_cloudwatch_event_rule" "auto_enable_alb_log_events" {
  count = local.enable_alb_log_events ? 1 : 0

  name        = "sumo-logic-alb-s3-${local.random_id_part}"
  description = "Auto-Enable S3 logging for ALB resources with Lambda from events"
  state       = "ENABLED"

  event_pattern = jsonencode({
    source      = ["aws.elasticloadbalancing"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["elasticloadbalancing.amazonaws.com"]
      eventName   = ["CreateLoadBalancer"]
    }
  })

  tags = var.aws_resource_tags
}

resource "aws_cloudwatch_event_target" "alb_lambda_target" {
  count = local.enable_alb_log_events ? 1 : 0

  rule      = aws_cloudwatch_event_rule.auto_enable_alb_log_events[0].name
  target_id = "Main"
  arn       = aws_lambda_function.enable_new_aws_resources[0].arn
}

resource "aws_lambda_permission" "alb_events_invoke_permission" {
  count = local.enable_alb_log_events ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.enable_new_aws_resources[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto_enable_alb_log_events[0].arn
}

# CloudWatch Event Rules and Permissions for ELB
resource "aws_cloudwatch_event_rule" "auto_enable_elb_log_events" {
  count = local.enable_elb_log_events ? 1 : 0

  name        = "sumo-logic-elb-s3-${local.random_id_part}"
  description = "Auto-Enable S3 logging for ELB classic resources with Lambda from events"
  state       = "ENABLED"

  event_pattern = jsonencode({
    source      = ["aws.elasticloadbalancing"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["elasticloadbalancing.amazonaws.com"]
      eventName   = ["CreateLoadBalancer"]
    }
  })

  tags = var.aws_resource_tags
}

resource "aws_cloudwatch_event_target" "elb_lambda_target" {
  count = local.enable_elb_log_events ? 1 : 0

  rule      = aws_cloudwatch_event_rule.auto_enable_elb_log_events[0].name
  target_id = "Main"
  arn       = aws_lambda_function.enable_new_aws_resources[0].arn
}

resource "aws_lambda_permission" "elb_events_invoke_permission" {
  count = local.enable_elb_log_events ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.enable_new_aws_resources[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto_enable_elb_log_events[0].arn
}

# Lambda Function for Existing AWS Resources
resource "aws_lambda_function" "enable_existing_aws_resources" {
  count = local.auto_enable_existing ? 1 : 0

  function_name = "EnableExistingAWSResourcesLambda-${local.random_id_part}"
  role         = aws_iam_role.sumo_lambda_role.arn
  handler      = "main.handler"
  runtime      = "python3.13"
  memory_size  = 128
  timeout      = 900

  s3_bucket = local.region_bucket_map[data.aws_region.current.id]
  s3_key    = "sumologic-aws-observability/functions/sumo-app-utils/v3.0.0/sumo-app-utils.zip"

  tags = var.aws_resource_tags

  depends_on = [aws_iam_role_policy.sumo_lambda_policy]
}

# Example resource usage

resource "lambda_invoke_extension_action" "enable_logging" {
  count = local.auto_enable_existing ? 1 : 0

  provider = lambda-invoke-extension
  lambda_name            = aws_lambda_function.enable_existing_aws_resources[0].function_name
  aws_resource           = local.aws_resource
  bucket_name            = var.bucket_name
  filter                 = var.filter_expression
  bucket_prefix          = var.bucket_prefix
  account_id             = data.aws_caller_identity.current.account_id
  remove_on_delete_stack = var.remove_on_delete_stack
}
