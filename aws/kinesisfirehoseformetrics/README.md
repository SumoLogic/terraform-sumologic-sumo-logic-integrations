# SumoLogic-AWS-KinesisFirehoseForMetrics

This module is used to create the SumoLogic AWS Kinesis Firehose for Metrics source. Features include
- Create an AWS S3 bucket for storing failed logs. Existing bucket can also be used.
- Create AWS resources to setup Kinesis Stream in AWS which includes AWS IAM role, Log Groups, Log Streams, Delivery streams.
- Create Sumo Logic hosted collector. Existing collector can also be used.
- Create Sumo Logic AWS Kinesis Firehose for Metrics source.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 3.42.0 |
| random | >= 3.1.0 |
| sumologic | >= 2.9.0 |
| time | >= 0.7.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.42.0 |
| random | >= 3.1.0 |
| sumologic | >= 2.9.0 |
| time | >= 0.7.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_details | Provide details for the AWS S3 bucket. If not provided, existing will be used. | <pre>object({<br>    bucket_name          = string<br>    force_destroy_bucket = bool<br>  })</pre> | <pre>{<br>  "bucket_name": "sumologic-kinesis-firehose-metrics-random-id",<br>  "force_destroy_bucket": true<br>}</pre> | no |
| collector\_details | Provide details for the Sumo Logic collector. If not provided, then defaults will be used. | <pre>object({<br>    collector_name = string<br>    description    = string<br>    fields         = map(string)<br>  })</pre> | <pre>{<br>  "collector_name": "SumoLogic Kinesis Firehose for Metrics Collector <Random ID>",<br>  "description": "This collector is created using Sumo Logic terraform AWS Kinesis Firehose for metrics module to collect AWS cloudwatch metrics.",<br>  "fields": {}<br>}</pre> | no |
| create\_bucket | Provide "true" if you would like to create AWS S3 bucket to store failed logs. Provide "bucket\_details" if set to "false". | `bool` | `true` | no |
| create\_collector | Provide "true" if you would like to create the Sumo Logic Collector. | `bool` | n/a | yes |
| source\_details | Provide details for the Sumo Logic Kinesis Firehose for Metrics source. If not provided, then defaults will be used. | <pre>object({<br>    source_name         = string<br>    source_category     = string<br>    collector_id        = string<br>    description         = string<br>    sumo_account_id     = number<br>    limit_to_namespaces = list(string)<br>    fields              = map(string)<br>    iam_role_arn        = string<br>  })</pre> | <pre>{<br>  "collector_id": "",<br>  "description": "This source is created using Sumo Logic terraform AWS Kinesis Firehose for metrics module to collect AWS Cloudwatch metrics.",<br>  "fields": {},<br>  "iam_role_arn": "",<br>  "limit_to_namespaces": [],<br>  "source_category": "Labs/aws/cloudwatch/metrics",<br>  "source_name": "Kinesis Firehose for Metrics Source",<br>  "sumo_account_id": 926226587429<br>}</pre> | no |
| sumologic\_organization\_id | Appears on the Account Overview page that displays information about your Sumo Logic organization. Used for IAM Role in Sumo Logic AWS Sources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_cloudwatch\_log\_group | AWS Log group created to attach to delivery stream. |
| aws\_cloudwatch\_log\_stream | AWS Log stream created to attach to log group. |
| aws\_cloudwatch\_metric\_stream | CloudWatch metrics stream to send metrics. |
| aws\_iam\_role | AWS IAM role with permission to setup kinesis firehose metrics. |
| aws\_kinesis\_firehose\_delivery\_stream | AWS Kinesis firehose delivery stream to send metrics to Sumo Logic. |
| aws\_s3\_bucket | AWS S3 Bucket name created to Store the Failed data. |
| random\_string | Random String value created. |
| source\_aws\_iam\_role | AWS IAM role with permission to setup Sumo Logic permissions. |
| sumologic\_collector | Sumo Logic hosted collector. |
| sumologic\_source | Sumo Logic AWS Kinesis Firehose for Metrics source. |
