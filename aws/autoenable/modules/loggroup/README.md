## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.16.2, < 7.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.1.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.16.2, < 7.0.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.1.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.7.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.sumo_log_group_lambda_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.sumo_log_group_existing_lambda_connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.sumo_log_group_lambda_connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.existing_lambda_invoke_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.kinesis_firehose_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.sumo_log_group_existing_lambda_connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.sumo_log_group_lambda_connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.auto_subscribe_cw_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.sumo_cw_lambda_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [null_resource.invoke_lambda_connector](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.stack_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait_for_iam_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [archive_file.existing_lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_resource_tags"></a> [aws\_resource\_tags](#input\_aws\_resource\_tags) | Map of tags to apply to all AWS resources provisioned through the Module | `map(string)` | `{}` | no |
| <a name="input_destination_arn_type"></a> [destination\_arn\_type](#input\_destination\_arn\_type) | Lambda - When the destination ARN for subscription filter is an AWS Lambda Function. Kinesis - When the destination ARN for subscription filter is an Kinesis or Amazon Kinesis data firehose stream. | `string` | `"Lambda"` | no |
| <a name="input_destination_arn_value"></a> [destination\_arn\_value](#input\_destination\_arn\_value) | Enter Destination ARN like Lambda function, Kinesis stream. For more information, visit - https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilters.html | `string` | `"arn:aws:lambda:us-east-1:123456789000:function:TestLambda"` | no |
| <a name="input_log_group_pattern"></a> [log\_group\_pattern](#input\_log\_group\_pattern) | Enter regex for matching logGroups | `string` | `"Test"` | no |
| <a name="input_log_group_tags"></a> [log\_group\_tags](#input\_log\_group\_tags) | Enter comma separated keyvalue pairs for filtering logGroups using tags. Ex KeyName1=string,KeyName2=string. This is optional leave it blank if tag based filtering is not needed. | `string` | `""` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | Enter AWS IAM Role arn in case the destination is Kinesis Firehose stream. | `string` | `""` | no |
| <a name="input_use_existing_logs"></a> [use\_existing\_logs](#input\_use\_existing\_logs) | Select true for subscribing existing logs | `string` | `"true"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sumo_log_group_lambda_connector_arn"></a> [sumo\_log\_group\_lambda\_connector\_arn](#output\_sumo\_log\_group\_lambda\_connector\_arn) | The ARN of the SumoLogGroupLambdaConnector function |
