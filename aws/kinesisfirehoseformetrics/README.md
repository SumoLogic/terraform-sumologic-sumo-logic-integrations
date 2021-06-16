# SumoLogic-AWS-CloudWatchMetrics

This module is used to create the SumoLogic AWS CloudWatch metrics source. Features include
- Create AWS IAM role or use an existing IAM role.
- Create Sumo Logic hosted collector or use an existing Sumo Logic hosted collector.
- Create Sumo Logic AWS CloudWatch metrics source.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | ~> 3.29.1 |
| sumologic | ~> 2.6.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.29.1 |
| sumologic | ~> 2.6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| collector\_details | Provide details for the Sumo Logic collector. If not provided, then defaults will be used. | <pre>object({<br>    collector_name = string<br>    description    = string<br>    fields         = map(string)<br>  })</pre> | <pre>{<br>  "collector_name": "SumoLogic CloudWatch Metrics Collector <AWS Account Id>",<br>  "description": "This collector is created using Sumo Logic terraform AWS Cloudwatch metrics module to collect AWS cloudwatch metrics.",<br>  "fields": {}<br>}</pre> | no |
| create\_collector | Provide "true" if you would like to create the Sumo Logic Collector. | `bool` | n/a | yes |
| source\_details | Provide details for the Sumo Logic Cloudwatch Metrics source. If not provided, then defaults will be used. | <pre>object({<br>    source_name     = string<br>    source_category = string<br>    collector_id    = string<br>    description     = string<br>    limit_to_regions = list(string)<br>    limit_to_namespaces = list(string)<br>    paused               = bool<br>    sumo_account_id      = number<br>    fields               = map(string)<br>    iam_role_arn         = string<br>  })</pre> | <pre>{<br>  "collector_id": "",<br>  "description": "This source is created using Sumo Logic terraform AWS CloudWatch Metrics module to collect AWS Cloudwatch metrics.",<br>  "fields": {},<br>  "iam_role_arn": "",<br>  "limit_to_namespaces": [],<br>  "limit_to_regions": [],<br>  "paused": false,<br>  "source_category": "Labs/aws/cloudwatch/metrics",<br>  "source_name": "CloudWatch Metrics Source",<br>  "sumo_account_id": 926226587429<br>}</pre> | no |
| sumologic\_organization\_id | Appears on the Account Overview page that displays information about your Sumo Logic organization. Used for IAM Role in Sumo Logic AWS Sources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_iam\_role | AWS IAM role with permission to allow Sumo Logic to read logs from S3 Bucket. |
| sumologic\_collector | Sumo Logic hosted collector. |
| sumologic\_source | Sumo Logic AWS Cloudwatch metrics source. |

