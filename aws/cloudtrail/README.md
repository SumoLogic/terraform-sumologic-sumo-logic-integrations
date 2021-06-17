# SumoLogic-AWS-CloudTrail

This module is used to create AWS and Sumo Logic resource to collect CloudTrail logs from an AWS S3 bucket. Features include
- Create AWS CloudTrail (when creating a new AWS S3 bucket) or use an existing AWS CloudTrail (Provide existing AWS S3 bucket name) which send data to S3.
- Create AWS S3 bucket or use an existing AWS S3 bucket.
- Create AWS IAM role or use an existing IAM role.
- Create AWS SNS Topic or use an existing AWS SNS topic.
- Create Sumo Logic hosted collector or use an existing Sumo Logic hosted collector.
- Create Sumo Logic CloudTrail source.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | ~> 3.42.0 |
| random | 3.1.0 |
| sumologic | ~> 2.9.0 |
| time | 0.7.1 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.42.0 |
| random | 3.1.0 |
| sumologic | ~> 2.9.0 |
| time | 0.7.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudtrail\_details | Provide details for the AWS CloudTrail. If not provided, then defaults will be used. | <pre>object({<br>    name                          = string<br>    is_multi_region_trail         = bool<br>    is_organization_trail         = bool<br>    include_global_service_events = bool<br>  })</pre> | <pre>{<br>  "include_global_service_events": false,<br>  "is_multi_region_trail": false,<br>  "is_organization_trail": false,<br>  "name": "SumoLogic-Terraform-CloudTrail-random-id"<br>}</pre> | no |
| collector\_details | Provide details for the Sumo Logic collector. If not provided, then defaults will be used. | <pre>object({<br>    collector_name = string<br>    description    = string<br>    fields         = map(string)<br>  })</pre> | <pre>{<br>  "collector_name": "SumoLogic CloudTrail Collector <Random ID>",<br>  "description": "This collector is created using Sumo Logic terraform AWS cloudtrail module to collect AWS cloudtrail logs.",<br>  "fields": {}<br>}</pre> | no |
| create\_collector | Provide "true" if you would like to create the Sumo Logic Collector. | `bool` | n/a | yes |
| create\_trail | Provide "true" if you would like to create the AWS CloudTrail. If the bucket is created by the module, module by default creates the AWS cloudtrail. | `bool` | n/a | yes |
| source\_details | Provide details for the Sumo Logic CloudTrail source. If not provided, then defaults will be used. | <pre>object({<br>    source_name     = string<br>    source_category = string<br>    collector_id    = string<br>    description     = string<br>    bucket_details = object({<br>      create_bucket        = bool<br>      bucket_name          = string<br>      path_expression      = string<br>      force_destroy_bucket = bool<br>    })<br>    paused               = bool<br>    scan_interval        = string<br>    sumo_account_id      = number<br>    cutoff_relative_time = string<br>    fields               = map(string)<br>    iam_role_arn         = string<br>    sns_topic_arn        = string<br>  })</pre> | <pre>{<br>  "bucket_details": {<br>    "bucket_name": "cloudtrail-logs-random-id",<br>    "create_bucket": true,<br>    "force_destroy_bucket": true,<br>    "path_expression": "AWSLogs/<ACCOUNT-ID>/CloudTrail/<REGION-NAME>/*"<br>  },<br>  "collector_id": "",<br>  "cutoff_relative_time": "-1d",<br>  "description": "This source is created using Sumo Logic terraform AWS cloudtrail module to collect AWS cloudtrail logs.",<br>  "fields": {},<br>  "iam_role_arn": "",<br>  "paused": false,<br>  "scan_interval": 300000,<br>  "sns_topic_arn": "",<br>  "source_category": "Labs/aws/cloudtrail",<br>  "source_name": "CloudTrail Source",<br>  "sumo_account_id": 926226587429<br>}</pre> | no |
| sumologic\_organization\_id | Appears on the Account Overview page that displays information about your Sumo Logic organization. Used for IAM Role in Sumo Logic AWS Sources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_cloudtrail | AWS Trail created to send CloudTrail logs to AWS S3 bucket. |
| aws\_iam\_role | AWS IAM role with permission to allow Sumo Logic to read logs from S3 Bucket. |
| aws\_s3\_bucket | AWS S3 Bucket name created to Store the CloudTrail logs. |
| aws\_s3\_bucket\_notification | AWS S3 Bucket Notification attached to the AWS S3 Bucket |
| aws\_sns\_subscription | AWS SNS subscription to Sumo Logic AWS CloudTrail source. |
| aws\_sns\_topic | AWS SNS topic attached to the AWS S3 bucket. |
| random\_string | Random String value created. |
| sumologic\_collector | Sumo Logic hosted collector. |
| sumologic\_source | Sumo Logic AWS CloudTrail source. |
