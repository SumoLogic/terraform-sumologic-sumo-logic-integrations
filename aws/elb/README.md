# SumoLogic-AWS-Elb

This module is used to create AWS and Sumo Logic resource to collect ELB logs from an AWS S3 bucket. Features include
- Create AWS S3 bucket or use an existing AWS S3 bucket.
- Create AWS IAM role or use an existing IAM role.
- Create AWS SNS Topic or use an existing AWS SNS topic.
- Create Sumo Logic hosted collector or use an existing Sumo Logic hosted collector.
- Create Sumo Logic ELB source.
- Auto enable access logs for Existing and New load balancer after installing the module.

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
| auto\_enable\_access\_logs | New - Automatically enables access logging for newly created ALB resources to collect logs for ALB resources. This does not affect ALB resources already collecting logs.<br>                              Existing - Automatically enables access logging for existing ALB resources to collect logs for ALB resources.<br>                               Both - Automatically enables access logging for new and existing ALB resources.<br>                               None - Skips Automatic access Logging enable for ALB resources. | `string` | `"Both"` | no |
| auto\_enable\_access\_logs\_options | filter - provide a regex to filter the ELB for which access logs should be enabled. Empty means all resources. For eg :- 'Type': 'application'\|'type': 'application', will enable access logs for Application load balancer only.<br>            remove\_on\_delete\_stack - provide true if you would like to disable access logging when you destroy the terraform resources. | <pre>object({<br>    filter                 = string<br>    remove_on_delete_stack = bool<br>  })</pre> | <pre>{<br>  "filter": "",<br>  "remove_on_delete_stack": true<br>}</pre> | no |
| collector\_details | Provide details for the Sumo Logic collector. If not provided, then defaults will be used. | <pre>object({<br>    collector_name = string<br>    description    = string<br>    fields         = map(string)<br>  })</pre> | <pre>{<br>  "collector_name": "SumoLogic Elb Collector <Random ID>",<br>  "description": "This collector is created using Sumo Logic terraform AWS ELB module to collect AWS elb logs.",<br>  "fields": {}<br>}</pre> | no |
| create\_collector | Provide "true" if you would like to create the Sumo Logic Collector. | `bool` | n/a | yes |
| source\_details | Provide details for the Sumo Logic ELB source. If not provided, then defaults will be used. | <pre>object({<br>    source_name     = string<br>    source_category = string<br>    collector_id    = string<br>    description     = string<br>    bucket_details = object({<br>      create_bucket        = bool<br>      bucket_name          = string<br>      path_expression      = string<br>      force_destroy_bucket = bool<br>    })<br>    paused               = bool<br>    scan_interval        = string<br>    sumo_account_id      = number<br>    cutoff_relative_time = string<br>    fields               = map(string)<br>    iam_role_arn         = string<br>    sns_topic_arn        = string<br>  })</pre> | <pre>{<br>  "bucket_details": {<br>    "bucket_name": "elb-logs-random-id",<br>    "create_bucket": true,<br>    "force_destroy_bucket": true,<br>    "path_expression": "*AWSLogs/<ACCOUNT-ID>/elasticloadbalancing/<REGION-NAME>/*"<br>  },<br>  "collector_id": "",<br>  "cutoff_relative_time": "-1d",<br>  "description": "This source is created using Sumo Logic terraform AWS elb module to collect AWS elb logs.",<br>  "fields": {},<br>  "iam_role_arn": "",<br>  "paused": false,<br>  "scan_interval": 300000,<br>  "sns_topic_arn": "",<br>  "source_category": "Labs/aws/elb",<br>  "source_name": "Elb Source",<br>  "sumo_account_id": 926226587429<br>}</pre> | no |
| sumologic\_organization\_id | Appears on the Account Overview page that displays information about your Sumo Logic organization. Used for IAM Role in Sumo Logic AWS Sources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_iam\_role | AWS IAM role with permission to allow Sumo Logic to read logs from S3 Bucket. |
| aws\_s3\_bucket | AWS S3 Bucket name created to Store the ELB logs. |
| aws\_s3\_bucket\_notification | AWS S3 Bucket Notification attached to the AWS S3 Bucket |
| aws\_serverlessapplicationrepository\_cloudformation\_stack | AWS CloudFormation stack for ALB Auto Enable access logs. |
| aws\_sns\_subscription | AWS SNS subscription to Sumo Logic AWS ELB source. |
| aws\_sns\_topic | AWS SNS topic attached to the AWS S3 bucket. |
| random\_string | Random String value created. |
| sumologic\_collector | Sumo Logic hosted collector. |
| sumologic\_source | Sumo Logic AWS ELB source. |
