# SumoLogic-AWS-CloudTrail

This module is used to create AWS and Sumo Logic resource to collect CloudTrail logs from an AWS S3 bucket. Features include
- Create AWS CloudTrail (when creating a new AWS S3 bucket) or use an existing AWS CloudTrail (Provide existing AWS S3 bucket name) which send data to S3.
- Create AWS S3 bucket or use an existing AWS S3 bucket.
- Create AWS IAM role or use an existing IAM role.
- Create AWS SNS Topic or use an existing AWS SNS topic.
- Create Sumo Logic hosted collector or use an existing Sumo Logic hosted collector.
- Create Sumo Logic CloudTrail source.

## Requirements

| Name | Version            |
|------|--------------------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7        |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.16.2, < 7.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.1.0            |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.31.3, < 4.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.7.1            |

## Providers

| Name | Version            |
|------|--------------------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.16.2, < 7.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.1.0            |
| <a name="provider_sumologic"></a> [sumologic](#provider\_sumologic) | >= 2.31.3, < 4.0.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.7.1            |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_iam_policy.iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.source_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.source-role-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_sns_topic.sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [random_string.aws_random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [sumologic_cloudtrail_source.source](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/cloudtrail_source) | resource |
| [sumologic_collector.collector](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/collector) | resource |
| [time_sleep.wait_for_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [sumologic_caller_identity.current](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudtrail_details"></a> [cloudtrail\_details](#input\_cloudtrail\_details) | Provide details for the AWS CloudTrail. If not provided, then defaults will be used. | <pre>object({<br/>    name                          = string<br/>    is_multi_region_trail         = bool<br/>    is_organization_trail         = bool<br/>    include_global_service_events = bool<br/>  })</pre> | <pre>{<br/>  "include_global_service_events": false,<br/>  "is_multi_region_trail": false,<br/>  "is_organization_trail": false,<br/>  "name": "SumoLogic-Terraform-CloudTrail-random-id"<br/>}</pre> | no |
| <a name="input_collector_details"></a> [collector\_details](#input\_collector\_details) | Provide details for the Sumo Logic collector. If not provided, then defaults will be used. | <pre>object({<br/>    collector_name = string<br/>    description    = string<br/>    fields         = map(string)<br/>  })</pre> | <pre>{<br/>  "collector_name": "SumoLogic CloudTrail Collector <Random ID>",<br/>  "description": "This collector is created using Sumo Logic terraform AWS cloudtrail module to collect AWS cloudtrail logs.",<br/>  "fields": {}<br/>}</pre> | no |
| <a name="input_create_collector"></a> [create\_collector](#input\_create\_collector) | Provide "true" if you would like to create the Sumo Logic Collector. | `bool` | n/a | yes |
| <a name="input_create_trail"></a> [create\_trail](#input\_create\_trail) | Provide "true" if you would like to create the AWS CloudTrail. If the bucket is created by the module, module by default creates the AWS cloudtrail. | `bool` | n/a | yes |
| <a name="input_source_details"></a> [source\_details](#input\_source\_details) | Provide details for the Sumo Logic CloudTrail source. If not provided, then defaults will be used. | <pre>object({<br/>    source_name     = string<br/>    source_category = string<br/>    collector_id    = string<br/>    description     = string<br/>    bucket_details = object({<br/>      create_bucket        = bool<br/>      bucket_name          = string<br/>      path_expression      = string<br/>      force_destroy_bucket = bool<br/>    })<br/>    paused               = bool<br/>    scan_interval        = string<br/>    sumo_account_id      = number<br/>    cutoff_relative_time = string<br/>    fields               = map(string)<br/>    iam_details = object({<br/>      create_iam_role = bool<br/>      iam_role_arn    = string<br/>    })<br/>    sns_topic_details = object({<br/>      create_sns_topic = bool<br/>      sns_topic_arn    = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "bucket_details": {<br/>    "bucket_name": "cloudtrail-logs-random-id",<br/>    "create_bucket": true,<br/>    "force_destroy_bucket": true,<br/>    "path_expression": "AWSLogs/<ACCOUNT-ID>/CloudTrail/<REGION-NAME>/*"<br/>  },<br/>  "collector_id": "",<br/>  "cutoff_relative_time": "-1d",<br/>  "description": "This source is created using Sumo Logic terraform AWS cloudtrail module to collect AWS cloudtrail logs.",<br/>  "fields": {},<br/>  "iam_details": {<br/>    "create_iam_role": true,<br/>    "iam_role_arn": null<br/>  },<br/>  "paused": false,<br/>  "scan_interval": 300000,<br/>  "sns_topic_details": {<br/>    "create_sns_topic": true,<br/>    "sns_topic_arn": null<br/>  },<br/>  "source_category": "Labs/aws/cloudtrail",<br/>  "source_name": "CloudTrail Source",<br/>  "sumo_account_id": 926226587429<br/>}</pre> | no |
| <a name="input_sumologic_organization_id"></a> [sumologic\_organization\_id](#input\_sumologic\_organization\_id) | Appears on the Account Overview page that displays information about your Sumo Logic organization. Used for IAM Role in Sumo Logic AWS Sources. | `string` | n/a | yes |
| <a name="input_wait_for_seconds"></a> [wait\_for\_seconds](#input\_wait\_for\_seconds) | wait\_for\_seconds is used to delay sumo logic source creation. This helps persisting IAM role in AWS system.<br/>        Default value is 180 seconds.<br/>        If the AWS IAM role is created outside the module, the value can be decreased to 1 second. | `number` | `180` | no |
| <a name="input_aws_resource_tags"></a> [aws\_resource\_tags](#input\_aws\_resource\_tags) | Map of tags to apply to all AWS resources provisioned through the Module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_cloudtrail"></a> [aws\_cloudtrail](#output\_aws\_cloudtrail) | AWS Trail created to send CloudTrail logs to AWS S3 bucket. |
| <a name="output_aws_iam_role"></a> [aws\_iam\_role](#output\_aws\_iam\_role) | AWS IAM role with permission to allow Sumo Logic to read logs from S3 Bucket. |
| <a name="output_aws_s3_bucket"></a> [aws\_s3\_bucket](#output\_aws\_s3\_bucket) | AWS S3 Bucket name created to Store the CloudTrail logs. |
| <a name="output_aws_s3_bucket_notification"></a> [aws\_s3\_bucket\_notification](#output\_aws\_s3\_bucket\_notification) | AWS S3 Bucket Notification attached to the AWS S3 Bucket |
| <a name="output_aws_sns_subscription"></a> [aws\_sns\_subscription](#output\_aws\_sns\_subscription) | AWS SNS subscription to Sumo Logic AWS CloudTrail source. |
| <a name="output_aws_sns_topic"></a> [aws\_sns\_topic](#output\_aws\_sns\_topic) | AWS SNS topic attached to the AWS S3 bucket. |
| <a name="output_random_string"></a> [random\_string](#output\_random\_string) | Random String value created. |
| <a name="output_sumologic_collector"></a> [sumologic\_collector](#output\_sumologic\_collector) | Sumo Logic hosted collector. |
| <a name="output_sumologic_source"></a> [sumologic\_source](#output\_sumologic\_source) | Sumo Logic AWS CloudTrail source. |
