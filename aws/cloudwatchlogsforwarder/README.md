# SumoLogic-AWS-CloudWatchLogsForwarder

This module is used to create the SumoLogic AWS HTTP source to collect AWS CloudWatch logs. Features include
- Create AWS resources to setup IAM Roles, SQS, SNS, Metric Alarm, Lambda functions.
- Create Sumo Logic hosted collector. Existing collector can also be used.
- Create Sumo Logic HTTP Source for logs.
- Auto enable logs subscription for Existing and New log groups after installing the module.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 3.42.0 |
| random | >= 3.1.0 |
| sumologic | >= 2.9.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.42.0 |
| random | >= 3.1.0 |
| sumologic | >= 2.9.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| auto\_enable\_logs\_subscription | New - Automatically subscribes new log groups to send logs to Sumo Logic.<br>                              Existing - Automatically subscribes existing log groups to send logs to Sumo Logic.<br>                           Both - Automatically subscribes new and existing log groups.<br>                                None - Skips Automatic subscription. | `string` | `"Both"` | no |
| auto\_enable\_logs\_subscription\_options | filter - Enter regex for matching logGroups. Regex will check for the name. Visit https://help.sumologic.com/03Send-Data/Collect-from-Other-Data-Sources/Auto-Subscribe_AWS_Log_Groups_to_a_Lambda_Function#Configuring_parameters | <pre>object({<br>    filter = string<br>  })</pre> | <pre>{<br>  "filter": "lambda"<br>}</pre> | no |
| collector\_details | Provide details for the Sumo Logic collector. If not provided, then defaults will be used. | <pre>object({<br>    collector_name = string<br>    description    = string<br>    fields         = map(string)<br>  })</pre> | <pre>{<br>  "collector_name": "SumoLogic CloudWatch Logs Collector <Random ID>",<br>  "description": "This collector is created using Sumo Logic terraform AWS CloudWatch Logs forwarder to collect AWS cloudwatch logs.",<br>  "fields": {}<br>}</pre> | no |
| create\_collector | Provide "true" if you would like to create the Sumo Logic Collector. | `bool` | n/a | yes |
| email\_id | Email for receiving alerts. A confirmation email is sent after the deployment is complete. It can be confirmed to subscribe for alerts. | `string` | `"test@gmail.com"` | no |
| include\_log\_group\_info | Enable loggroup/logstream values in logs. | `bool` | `true` | no |
| log\_format | Service for Cloudwatch logs source. | `string` | `"Others"` | no |
| log\_stream\_prefix | LogStream name prefixes to filter by logStream. Please note this is separate from a logGroup. This is used only to send certain logStreams within a Cloudwatch logGroup(s). LogGroups still need to be subscribed to the created Lambda function regardless of this input value. | `list(string)` | `[]` | no |
| source\_details | Provide details for the Sumo Logic HTTP source. If not provided, then defaults will be used. | <pre>object({<br>    source_name     = string<br>    source_category = string<br>    collector_id    = string<br>    description     = string<br>    fields          = map(string)<br>  })</pre> | <pre>{<br>  "collector_id": "",<br>  "description": "This source is created using Sumo Logic terraform AWS CloudWatch Logs forwarder to collect AWS cloudwatch logs.",<br>  "fields": {},<br>  "source_category": "Labs/aws/cloudwatch",<br>  "source_name": "CloudWatch Logs Source"<br>}</pre> | no |
| workers | Number of lambda function invocations for Cloudwatch logs source Dead Letter Queue processing. | `number` | `4` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_cloudwatch\_log\_group | AWS Log group created to attach to the lambda function. |
| aws\_cloudwatch\_metric\_alarm | AWS CLoudWatch metric alarm. |
| aws\_cw\_lambda\_function | AWS Lambda fucntion to send logs to Sumo Logic. |
| aws\_iam\_role | AWS IAM role with permission to setup lambda. |
| aws\_serverlessapplicationrepository\_cloudformation\_stack | AWS CloudFormation stack for Auto Enable logs subscription. |
| aws\_sns\_topic | AWS SNS topic |
| aws\_sqs\_queue | AWS SQS queue to Store the Failed data. |
| random\_string | Random String value created. |
| sumologic\_collector | Sumo Logic hosted collector. |
| sumologic\_source | Sumo Logic HTTP source. |
