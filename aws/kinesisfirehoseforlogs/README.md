# SumoLogic-AWS-KinesisFirehoseForLogs

This module is used to create the SumoLogic AWS Kinesis Firehose for Logs source. Features include
- Create an AWS S3 bucket for storing failed logs. Existing bucket can also be used.
- Create AWS resources to setup Kinesis Stream in AWS which includes AWS IAM role, Log Groups, Log Streams, Delivery streams.
- Create Sumo Logic hosted collector. Existing collector can also be used.
- Create Sumo Logic AWS Kinesis Firehose for logs source.
- Auto enable logs subscription for Existing and New log groups after installing the module.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | ~> 3.42.0 |
| random | 3.1.0 |
| sumologic | ~> 2.9.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.42.0 |
| random | 3.1.0 |
| sumologic | ~> 2.9.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| auto\_enable\_logs\_subscription | New - Automatically subscribes new log groups to send logs to Sumo Logic.<br>                              Existing - Automatically subscribes existing log groups to send logs to Sumo Logic.<br>                           Both - Automatically subscribes new and existing log groups.<br>                                None - Skips Automatic subscription. | `string` | `"Both"` | no |
| auto\_enable\_logs\_subscription\_options | filter - Enter regex for matching logGroups. Regex will check for the name. Visit https://help.sumologic.com/03Send-Data/Collect-from-Other-Data-Sources/Auto-Subscribe_AWS_Log_Groups_to_a_Lambda_Function#Configuring_parameters | <pre>object({<br>    filter = string<br>  })</pre> | <pre>{<br>  "filter": "lambda"<br>}</pre> | no |
| bucket\_details | Provide details for the AWS S3 bucket. If not provided, existing will be used. | <pre>object({<br>    bucket_name          = string<br>    force_destroy_bucket = bool<br>  })</pre> | <pre>{<br>  "bucket_name": "sumologic-kinesis-firehose-logs-accountid-region",<br>  "force_destroy_bucket": true<br>}</pre> | no |
| collector\_details | Provide details for the Sumo Logic collector. If not provided, then defaults will be used. | <pre>object({<br>    collector_name = string<br>    description    = string<br>    fields         = map(string)<br>  })</pre> | <pre>{<br>  "collector_name": "SumoLogic Kinesis Firehose for Logs Collector <AWS Account Id>",<br>  "description": "This collector is created using Sumo Logic terraform AWS Kinesis Firehose for logs module to collect AWS cloudwatch logs.",<br>  "fields": {}<br>}</pre> | no |
| create\_bucket | Provide "true" if you would like to create AWS S3 bucket to store logs. Provide "bucket\_details" if set to "false". | `bool` | `true` | no |
| create\_collector | Provide "true" if you would like to create the Sumo Logic Collector. | `bool` | n/a | yes |
| source\_details | Provide details for the Sumo Logic Kinesis Firehose for Logs source. If not provided, then defaults will be used. | <pre>object({<br>    source_name     = string<br>    source_category = string<br>    collector_id    = string<br>    description     = string<br>    fields          = map(string)<br>  })</pre> | <pre>{<br>  "collector_id": "",<br>  "description": "This source is created using Sumo Logic terraform AWS Kinesis Firehose for logs module to collect AWS Cloudwatch logs.",<br>  "fields": {},<br>  "source_category": "Labs/aws/cloudwatch/logs",<br>  "source_name": "Kinesis Firehose for Logs Source"<br>}</pre> | no |
| sumologic\_organization\_id | Appears on the Account Overview page that displays information about your Sumo Logic organization. Used for IAM Role in Sumo Logic AWS Sources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_cloudwatch\_log\_group | AWS Log group created to attach to delivery stream. |
| aws\_cloudwatch\_log\_stream | AWS Log stream created to attach to log group. |
| aws\_iam\_role | AWS IAM role with permission to setup kinesis firehose logs. |
| aws\_kinesis\_firehose\_delivery\_stream | AWS Kinesis firehose delivery stream to send logs to Sumo Logic. |
| aws\_s3\_bucket | AWS S3 Bucket name created to Store the Failed data. |
| aws\_serverlessapplicationrepository\_cloudformation\_stack | AWS CloudFormation stack for Auto Enable logs subscription. |
| sumologic\_collector | Sumo Logic hosted collector. |
| sumologic\_source | Sumo Logic AWS Kinesis Firehose for Logs source. |
