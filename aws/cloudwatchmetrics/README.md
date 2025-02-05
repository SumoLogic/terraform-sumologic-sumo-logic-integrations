# SumoLogic-AWS-CloudWatchMetrics

This module is used to create the SumoLogic AWS CloudWatch metrics source. Features include
- Create AWS IAM role or use an existing IAM role.
- Create Sumo Logic hosted collector or use an existing Sumo Logic hosted collector.
- Create Sumo Logic AWS CloudWatch metrics source.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.16.2, < 6.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.1.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.31.3, < 4.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.16.2, < 6.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.1.0 |
| <a name="provider_sumologic"></a> [sumologic](#provider\_sumologic) | >= 2.31.3, < 4.0.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.7.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.source_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [random_string.aws_random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [sumologic_cloudwatch_source.cloudwatch_metrics_sources](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/cloudwatch_source) | resource |
| [sumologic_collector.collector](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/collector) | resource |
| [time_sleep.wait_for_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [sumologic_caller_identity.current](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_collector_details"></a> [collector\_details](#input\_collector\_details) | Provide details for the Sumo Logic collector. If not provided, then defaults will be used. | <pre>object({<br/>    collector_name = string<br/>    description    = string<br/>    fields         = map(string)<br/>  })</pre> | <pre>{<br/>  "collector_name": "SumoLogic CloudWatch Metrics Collector <Random ID>",<br/>  "description": "This collector is created using Sumo Logic terraform AWS Cloudwatch metrics module to collect AWS cloudwatch metrics.",<br/>  "fields": {}<br/>}</pre> | no |
| <a name="input_create_collector"></a> [create\_collector](#input\_create\_collector) | Provide "true" if you would like to create the Sumo Logic Collector. | `bool` | n/a | yes |
| <a name="input_source_details"></a> [source\_details](#input\_source\_details) | Provide details for the Sumo Logic Cloudwatch Metrics source. If not provided, then defaults will be used. | <pre>object({<br/>    source_name         = string<br/>    source_category     = string<br/>    collector_id        = string<br/>    description         = string<br/>    limit_to_regions    = list(string)<br/>    limit_to_namespaces = list(string)<br/>    tag_filters = list(object({<br/>      type      = string<br/>      namespace = string<br/>      tags      = list(string)<br/>    }))<br/>    paused              = bool<br/>    scan_interval       = number<br/>    sumo_account_id     = number<br/>    fields              = map(string)<br/>    iam_details = object({<br/>      create_iam_role = bool<br/>      iam_role_arn    = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "collector_id": "",<br/>  "description": "This source is created using Sumo Logic terraform AWS CloudWatch Metrics module to collect AWS Cloudwatch metrics.",<br/>  "fields": {},<br/>  "iam_details": {<br/>    "create_iam_role": true,<br/>    "iam_role_arn": null<br/>  },<br/>  "limit_to_namespaces": [<br/>    "AWS/ApplicationELB",<br/>    "AWS/ApiGateway",<br/>    "AWS/DynamoDB",<br/>    "AWS/Lambda",<br/>    "AWS/RDS",<br/>    "AWS/ECS",<br/>    "AWS/ElastiCache",<br/>    "AWS/ELB",<br/>    "AWS/NetworkELB",<br/>    "AWS/SQS",<br/>    "AWS/SNS"<br/>  ],<br/>  "limit_to_regions": [<br/>    "us-east-1"<br/>  ],<br/>  "paused": false,<br/>  "scan_interval": 300000,<br/>  "source_category": "Labs/aws/cloudwatch/metrics",<br/>  "source_name": "CloudWatch Metrics Source",<br/>  "sumo_account_id": 926226587429,<br/>  "tag_filters": []<br/>}</pre> | no |
| <a name="input_sumologic_organization_id"></a> [sumologic\_organization\_id](#input\_sumologic\_organization\_id) | Appears on the Account Overview page that displays information about your Sumo Logic organization. Used for IAM Role in Sumo Logic AWS Sources. | `string` | n/a | yes |
| <a name="input_wait_for_seconds"></a> [wait\_for\_seconds](#input\_wait\_for\_seconds) | wait\_for\_seconds is used to delay sumo logic source creation. This helps persisting IAM role in AWS system.<br/>        Default value is 180 seconds.<br/>        If the AWS IAM role is created outside the module, the value can be decreased to 1 second. | `number` | `180` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_iam_role"></a> [aws\_iam\_role](#output\_aws\_iam\_role) | AWS IAM role with permission to allow Sumo Logic to read logs from S3 Bucket. |
| <a name="output_random_string"></a> [random\_string](#output\_random\_string) | Random String value created. |
| <a name="output_sumologic_collector"></a> [sumologic\_collector](#output\_sumologic\_collector) | Sumo Logic hosted collector. |
| <a name="output_sumologic_source"></a> [sumologic\_source](#output\_sumologic\_source) | Sumo Logic AWS Cloudwatch metrics source. |
