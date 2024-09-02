# SumoLogic-AWS-KinesisFirehoseForMetrics

This module is used to create the SumoLogic AWS Kinesis Firehose for Metrics source. Features include
- Create an AWS S3 bucket for storing failed logs. Existing bucket can also be used.
- Create AWS resources to setup Kinesis Stream in AWS which includes AWS IAM role, Log Groups, Log Streams, Delivery streams.
- Create Sumo Logic hosted collector. Existing collector can also be used.
- Create Sumo Logic AWS Kinesis Firehose for Metrics source.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.16.2, < 6.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.31.3, < 3.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.16.2, < 6.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |
| <a name="provider_sumologic"></a> [sumologic](#provider\_sumologic) | >= 2.31.3, < 3.0.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.7.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.http_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_stream.s3_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_metric_stream.metric_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_stream) | resource |
| [aws_iam_policy.firehose_delivery_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.firehose_s3_upload_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.metrics_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.firehose_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.metrics_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.source_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.firehose_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.firehose_s3_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.metrics_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_firehose_delivery_stream.metrics_delivery_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.s3_bucket_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [random_string.aws_random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [sumologic_collector.collector](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/collector) | resource |
| [sumologic_kinesis_metrics_source.source](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/kinesis_metrics_source) | resource |
| [time_sleep.wait_for_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [sumologic_caller_identity.current](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_details"></a> [bucket\_details](#input\_bucket\_details) | Provide details for the AWS S3 bucket. If not provided, existing will be used. | <pre>object({<br>    bucket_name          = string<br>    force_destroy_bucket = bool<br>  })</pre> | <pre>{<br>  "bucket_name": "sumologic-kinesis-firehose-metrics-random-id",<br>  "force_destroy_bucket": true<br>}</pre> | no |
| <a name="input_collector_details"></a> [collector\_details](#input\_collector\_details) | Provide details for the Sumo Logic collector. If not provided, then defaults will be used. | <pre>object({<br>    collector_name = string<br>    description    = string<br>    fields         = map(string)<br>  })</pre> | <pre>{<br>  "collector_name": "SumoLogic Kinesis Firehose for Metrics Collector <Random ID>",<br>  "description": "This collector is created using Sumo Logic terraform AWS Kinesis Firehose for metrics module to collect AWS cloudwatch metrics.",<br>  "fields": {}<br>}</pre> | no |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket) | Provide "true" if you would like to create AWS S3 bucket to store failed logs. Provide "bucket\_details" if set to "false". | `bool` | `true` | no |
| <a name="input_create_collector"></a> [create\_collector](#input\_create\_collector) | Provide "true" if you would like to create the Sumo Logic Collector. | `bool` | n/a | yes |
| <a name="input_source_details"></a> [source\_details](#input\_source\_details) | Provide details for the Sumo Logic Kinesis Firehose for Metrics source. If not provided, then defaults will be used. | <pre>object({<br>    source_name         = string<br>    source_category     = string<br>    collector_id        = string<br>    description         = string<br>    sumo_account_id     = number<br>    limit_to_namespaces = list(string)<br>    fields              = map(string)<br>    iam_details = object({<br>      create_iam_role = bool<br>      iam_role_arn    = string<br>    })<br>  })</pre> | <pre>{<br>  "collector_id": "",<br>  "description": "This source is created using Sumo Logic terraform AWS Kinesis Firehose for metrics module to collect AWS Cloudwatch metrics.",<br>  "fields": {},<br>  "iam_details": {<br>    "create_iam_role": true,<br>    "iam_role_arn": null<br>  },<br>  "limit_to_namespaces": [],<br>  "source_category": "Labs/aws/cloudwatch/metrics",<br>  "source_name": "Kinesis Firehose for Metrics Source",<br>  "sumo_account_id": 926226587429<br>}</pre> | no |
| <a name="input_sumologic_organization_id"></a> [sumologic\_organization\_id](#input\_sumologic\_organization\_id) | Appears on the Account Overview page that displays information about your Sumo Logic organization. Used for IAM Role in Sumo Logic AWS Sources. | `string` | n/a | yes |
| <a name="input_wait_for_seconds"></a> [wait\_for\_seconds](#input\_wait\_for\_seconds) | wait\_for\_seconds is used to delay sumo logic source creation. This helps persisting IAM role in AWS system.<br>        Default value is 180 seconds.<br>        If the AWS IAM role is created outside the module, the value can be decreased to 1 second. | `number` | `180` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_cloudwatch_log_group"></a> [aws\_cloudwatch\_log\_group](#output\_aws\_cloudwatch\_log\_group) | AWS Log group created to attach to delivery stream. |
| <a name="output_aws_cloudwatch_log_stream"></a> [aws\_cloudwatch\_log\_stream](#output\_aws\_cloudwatch\_log\_stream) | AWS Log stream created to attach to log group. |
| <a name="output_aws_cloudwatch_metric_stream"></a> [aws\_cloudwatch\_metric\_stream](#output\_aws\_cloudwatch\_metric\_stream) | CloudWatch metrics stream to send metrics. |
| <a name="output_aws_iam_role"></a> [aws\_iam\_role](#output\_aws\_iam\_role) | AWS IAM role with permission to setup kinesis firehose metrics. |
| <a name="output_aws_kinesis_firehose_delivery_stream"></a> [aws\_kinesis\_firehose\_delivery\_stream](#output\_aws\_kinesis\_firehose\_delivery\_stream) | AWS Kinesis firehose delivery stream to send metrics to Sumo Logic. |
| <a name="output_aws_s3_bucket"></a> [aws\_s3\_bucket](#output\_aws\_s3\_bucket) | AWS S3 Bucket name created to Store the Failed data. |
| <a name="output_random_string"></a> [random\_string](#output\_random\_string) | Random String value created. |
| <a name="output_source_aws_iam_role"></a> [source\_aws\_iam\_role](#output\_source\_aws\_iam\_role) | AWS IAM role with permission to setup Sumo Logic permissions. |
| <a name="output_sumologic_collector"></a> [sumologic\_collector](#output\_sumologic\_collector) | Sumo Logic hosted collector. |
| <a name="output_sumologic_source"></a> [sumologic\_source](#output\_sumologic\_source) | Sumo Logic AWS Kinesis Firehose for Metrics source. |
