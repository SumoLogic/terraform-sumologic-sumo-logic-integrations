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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.16.2, < 6.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.31.0, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.16.2, < 6.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |
| <a name="provider_sumologic"></a> [sumologic](#provider\_sumologic) | >= 2.31.0, < 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.http_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_stream.s3_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_subscription_filter.delivery_stream_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_iam_policy.firehose_delivery_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.firehose_s3_upload_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.firehose_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.logs_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.firehose_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.firehose_s3_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.logs_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_firehose_delivery_stream.logs_delivery_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.s3_bucket_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_serverlessapplicationrepository_cloudformation_stack.auto_enable_logs_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/serverlessapplicationrepository_cloudformation_stack) | resource |
| [random_string.aws_random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [sumologic_collector.collector](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/collector) | resource |
| [sumologic_http_source.source](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/http_source) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_serverlessapplicationrepository_application.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/serverlessapplicationrepository_application) | data source |
| [sumologic_caller_identity.current](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name                                                                                                                                                      | Description                                                                                                                                                                                                                                                                          | Type                                                                                                                                                                                             | Default                                                                                                                                                                                                                                                                                                                | Required |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------:|
| <a name="input_app_semantic_version"></a> [app\_semantic\_version](#input\_app\_semantic\_version)                                                        | Provide the latest version of Serverless Application Repository 'sumologic-loggroup-connector'.                                                                                                                                                                                      | `string`                                                                                                                                                                                         | `"1.0.11"`                                                                                                                                                                                                                                                                                                             |    no    |
| <a name="input_auto_enable_logs_subscription"></a> [auto\_enable\_logs\_subscription](#input\_auto\_enable\_logs\_subscription)                           | New - Automatically subscribes new log groups to send logs to Sumo Logic.<br>				Existing - Automatically subscribes existing log groups to send logs to Sumo Logic.<br>				Both - Automatically subscribes new and existing log groups.<br>				None - Skips Automatic subscription. | `string`                                                                                                                                                                                         | `"Both"`                                                                                                                                                                                                                                                                                                               |    no    |
| <a name="input_auto_enable_logs_subscription_options"></a> [auto\_enable\_logs\_subscription\_options](#input\_auto\_enable\_logs\_subscription\_options) | filter - Enter regex for matching logGroups. Regex will check for the name. Visit https://help.sumologic.com/03Send-Data/Collect-from-Other-Data-Sources/Auto-Subscribe_AWS_Log_Groups_to_a_Lambda_Function#Configuring_parameters                                                   | <pre>object({<br>    filter = string<br>  })</pre>                                                                                                                                               | <pre>{<br>  "filter": "lambda"<br>}</pre>                                                                                                                                                                                                                                                                              |    no    |
| <a name="input_bucket_details"></a> [bucket\_details](#input\_bucket\_details)                                                                            | Provide details for the AWS S3 bucket. If not provided, existing will be used.                                                                                                                                                                                                       | <pre>object({<br>    bucket_name          = string<br>    force_destroy_bucket = bool<br>  })</pre>                                                                                              | <pre>{<br>  "bucket_name": "sumologic-kinesis-firehose-logs-random-id",<br>  "force_destroy_bucket": true<br>}</pre>                                                                                                                                                                                                   |    no    |
| <a name="input_collector_details"></a> [collector\_details](#input\_collector\_details)                                                                   | Provide details for the Sumo Logic collector. If not provided, then defaults will be used.                                                                                                                                                                                           | <pre>object({<br>    collector_name = string<br>    description    = string<br>    fields         = map(string)<br>  })</pre>                                                                    | <pre>{<br>  "collector_name": "SumoLogic Kinesis Firehose for Logs Collector <Random ID>",<br>  "description": "This collector is created using Sumo Logic terraform AWS Kinesis Firehose for logs module to collect AWS cloudwatch logs.",<br>  "fields": {}<br>}</pre>                                               |    no    |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket)                                                                               | Provide "true" if you would like to create AWS S3 bucket to store logs. Provide "bucket\_details" if set to "false".                                                                                                                                                                 | `bool`                                                                                                                                                                                           | `true`                                                                                                                                                                                                                                                                                                                 |    no    |
| <a name="input_create_collector"></a> [create\_collector](#input\_create\_collector)                                                                      | Provide "true" if you would like to create the Sumo Logic Collector.                                                                                                                                                                                                                 | `bool`                                                                                                                                                                                           | n/a                                                                                                                                                                                                                                                                                                                    |   yes    |
| <a name="input_source_details"></a> [source\_details](#input\_source\_details)                                                                            | Provide details for the Sumo Logic Kinesis Firehose for Logs source. If not provided, then defaults will be used.                                                                                                                                                                    | <pre>object({<br>    source_name     = string<br>    source_category = string<br>    collector_id    = string<br>    description     = string<br>    fields          = map(string)<br>  })</pre> | <pre>{<br>  "collector_id": "",<br>  "description": "This source is created using Sumo Logic terraform AWS Kinesis Firehose for logs module to collect AWS Cloudwatch logs.",<br>  "fields": {},<br>  "source_category": "Labs/aws/cloudwatch/logs",<br>  "source_name": "Kinesis Firehose for Logs Source"<br>}</pre> |    no    |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_cloudwatch_log_group"></a> [aws\_cloudwatch\_log\_group](#output\_aws\_cloudwatch\_log\_group) | AWS Log group created to attach to delivery stream. |
| <a name="output_aws_cloudwatch_log_stream"></a> [aws\_cloudwatch\_log\_stream](#output\_aws\_cloudwatch\_log\_stream) | AWS Log stream created to attach to log group. |
| <a name="output_aws_iam_role"></a> [aws\_iam\_role](#output\_aws\_iam\_role) | AWS IAM role with permission to setup kinesis firehose logs. |
| <a name="output_aws_kinesis_firehose_delivery_stream"></a> [aws\_kinesis\_firehose\_delivery\_stream](#output\_aws\_kinesis\_firehose\_delivery\_stream) | AWS Kinesis firehose delivery stream to send logs to Sumo Logic. |
| <a name="output_aws_s3_bucket"></a> [aws\_s3\_bucket](#output\_aws\_s3\_bucket) | AWS S3 Bucket name created to Store the Failed data. |
| <a name="output_aws_serverlessapplicationrepository_cloudformation_stack"></a> [aws\_serverlessapplicationrepository\_cloudformation\_stack](#output\_aws\_serverlessapplicationrepository\_cloudformation\_stack) | AWS CloudFormation stack for Auto Enable logs subscription. |
| <a name="output_random_string"></a> [random\_string](#output\_random\_string) | Random String value created. |
| <a name="output_sumologic_collector"></a> [sumologic\_collector](#output\_sumologic\_collector) | Sumo Logic hosted collector. |
| <a name="output_sumologic_source"></a> [sumologic\_source](#output\_sumologic\_source) | Sumo Logic AWS Kinesis Firehose for Logs source. |
