# SumoLogic-AWS-CloudWatchLogsForwarder

This module is used to create the SumoLogic AWS HTTP source to collect AWS CloudWatch logs. Features include
- Create AWS resources to setup IAM Roles, SQS, SNS, Metric Alarm, Lambda functions.
- Create Sumo Logic hosted collector. Existing collector can also be used.
- Create Sumo Logic HTTP Source for logs.
- Auto enable logs subscription for Existing and New log groups after installing the module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7        |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.16.2, < 7.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.31.3, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.16.2, < 7.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |
| <a name="provider_sumologic"></a> [sumologic](#provider\_sumologic) | >= 2.31.3, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.process_dead_letter_queue_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.process_dead_letter_queue_event_rule_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_subscription_filter.cloudwatch_log_subscription_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_cloudwatch_metric_alarm.metric_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_policy.create_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.invoke_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_sqs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.create_logs_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.invoke_lambda_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_sqs_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.logs_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.process_dead_letter_queue_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.logs_lambda_invoke_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.process_dead_letter_queue_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_serverlessapplicationrepository_cloudformation_stack.auto_enable_logs_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/serverlessapplicationrepository_cloudformation_stack) | resource |
| [aws_sns_topic.sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.sns_topic_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sqs_queue.sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [random_string.aws_random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [sumologic_collector.collector](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/collector) | resource |
| [sumologic_http_source.source](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/http_source) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_serverlessapplicationrepository_application.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/serverlessapplicationrepository_application) | data source |
| [sumologic_caller_identity.current](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_semantic_version"></a> [app\_semantic\_version](#input\_app\_semantic\_version) | Provide the latest version of Serverless Application Repository 'sumologic-loggroup-connector'. | `string` | `"1.0.14"` | no |
| <a name="input_auto_enable_logs_subscription"></a> [auto\_enable\_logs\_subscription](#input\_auto\_enable\_logs\_subscription) | New - Automatically subscribes new log groups to send logs to Sumo Logic.<br/>				Existing - Automatically subscribes existing log groups to send logs to Sumo Logic.<br/>				Both - Automatically subscribes new and existing log groups.<br/>				None - Skips Automatic subscription. | `string` | `"Both"` | no |
| <a name="input_auto_enable_logs_subscription_options"></a> [auto\_enable\_logs\_subscription\_options](#input\_auto\_enable\_logs\_subscription\_options) | filter - Enter regex for matching logGroups. Regex will check for the name.<br/>        tags\_filter - Enter comma separated key value pairs for filtering logGroups using tags. Ex KeyName1=string,KeyName2=string. This is optional leave it blank if tag based filtering is not needed.<br/>        Visit https://help.sumologic.com/docs/send-data/collect-from-other-data-sources/autosubscribe-arn-destination/#configuringparameters | <pre>object({<br/>    filter = string<br/>    tags_filter = string<br/>  })</pre> | <pre>{<br/>  "filter": "lambda",<br/>  "tags_filter": ""<br/>}</pre> | no |
| <a name="input_collector_details"></a> [collector\_details](#input\_collector\_details) | Provide details for the Sumo Logic collector. If not provided, then defaults will be used. | <pre>object({<br/>    collector_name = string<br/>    description    = string<br/>    fields         = map(string)<br/>  })</pre> | <pre>{<br/>  "collector_name": "SumoLogic CloudWatch Logs Collector <Random ID>",<br/>  "description": "This collector is created using Sumo Logic terraform AWS CloudWatch Logs forwarder to collect AWS cloudwatch logs.",<br/>  "fields": {}<br/>}</pre> | no |
| <a name="input_create_collector"></a> [create\_collector](#input\_create\_collector) | Provide "true" if you would like to create the Sumo Logic Collector. | `bool` | n/a | yes |
| <a name="input_email_id"></a> [email\_id](#input\_email\_id) | Email for receiving alerts. A confirmation email is sent after the deployment is complete. It can be confirmed to subscribe for alerts. | `string` | `"test@gmail.com"` | no |
| <a name="input_include_log_group_info"></a> [include\_log\_group\_info](#input\_include\_log\_group\_info) | Enable loggroup/logstream values in logs. | `bool` | `true` | no |
| <a name="input_log_format"></a> [log\_format](#input\_log\_format) | Service for Cloudwatch logs source. | `string` | `"Others"` | no |
| <a name="input_log_stream_prefix"></a> [log\_stream\_prefix](#input\_log\_stream\_prefix) | LogStream name prefixes to filter by logStream. Please note this is separate from a logGroup. This is used only to send certain logStreams within a Cloudwatch logGroup(s). LogGroups still need to be subscribed to the created Lambda function regardless of this input value. | `list(string)` | `[]` | no |
| <a name="input_source_details"></a> [source\_details](#input\_source\_details) | Provide details for the Sumo Logic HTTP source. If not provided, then defaults will be used. | <pre>object({<br/>    source_name     = string<br/>    source_category = string<br/>    collector_id    = string<br/>    description     = string<br/>    fields          = map(string)<br/>  })</pre> | <pre>{<br/>  "collector_id": "",<br/>  "description": "This source is created using Sumo Logic terraform AWS CloudWatch Logs forwarder to collect AWS cloudwatch logs.",<br/>  "fields": {},<br/>  "source_category": "Labs/aws/cloudwatch",<br/>  "source_name": "CloudWatch Logs Source"<br/>}</pre> | no |
| <a name="input_workers"></a> [workers](#input\_workers) | Number of lambda function invocations for Cloudwatch logs source Dead Letter Queue processing. | `number` | `4` | no |
| <a name="input_aws_resource_tags"></a> [aws\_resource\_tags](#input\_aws\_resource\_tags) | Map of tags to apply to all AWS resources provisioned through the Module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_cloudwatch_log_group"></a> [aws\_cloudwatch\_log\_group](#output\_aws\_cloudwatch\_log\_group) | AWS Log group created to attach to the lambda function. |
| <a name="output_aws_cloudwatch_metric_alarm"></a> [aws\_cloudwatch\_metric\_alarm](#output\_aws\_cloudwatch\_metric\_alarm) | AWS CLoudWatch metric alarm. |
| <a name="output_aws_cw_lambda_function"></a> [aws\_cw\_lambda\_function](#output\_aws\_cw\_lambda\_function) | AWS Lambda fucntion to send logs to Sumo Logic. |
| <a name="output_aws_iam_role"></a> [aws\_iam\_role](#output\_aws\_iam\_role) | AWS IAM role with permission to setup lambda. |
| <a name="output_aws_serverlessapplicationrepository_cloudformation_stack"></a> [aws\_serverlessapplicationrepository\_cloudformation\_stack](#output\_aws\_serverlessapplicationrepository\_cloudformation\_stack) | AWS CloudFormation stack for Auto Enable logs subscription. |
| <a name="output_aws_sns_topic"></a> [aws\_sns\_topic](#output\_aws\_sns\_topic) | AWS SNS topic |
| <a name="output_aws_sqs_queue"></a> [aws\_sqs\_queue](#output\_aws\_sqs\_queue) | AWS SQS queue to Store the Failed data. |
| <a name="output_random_string"></a> [random\_string](#output\_random\_string) | Random String value created. |
| <a name="output_sumologic_collector"></a> [sumologic\_collector](#output\_sumologic\_collector) | Sumo Logic hosted collector. |
| <a name="output_sumologic_source"></a> [sumologic\_source](#output\_sumologic\_source) | Sumo Logic HTTP source. |
