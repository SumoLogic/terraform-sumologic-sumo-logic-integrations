## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.16.2, < 7.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >=3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_loggroup_auto_enable_module"></a> [loggroup\_auto\_enable\_module](#module\_loggroup\_auto\_enable\_module) | SumoLogic/sumo-logic-integrations/sumologic//aws/autoenable/modules/loggroup | 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [random_string.aws_random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_resource_tags"></a> [aws\_resource\_tags](#input\_aws\_resource\_tags) | Map of tags to apply to all AWS resources provisioned through the Module | `map(string)` | `{}` | no |
| <a name="input_destination_arn_type"></a> [destination\_arn\_type](#input\_destination\_arn\_type) | Lambda - When the destination ARN for subscription filter is an AWS Lambda Function. Kinesis - When the destination ARN for subscription filter is an Kinesis or Amazon Kinesis data firehose stream. | `string` | `"Lambda"` | no |
| <a name="input_destination_arn_value"></a> [destination\_arn\_value](#input\_destination\_arn\_value) | Enter Destination ARN like Lambda function, Kinesis stream. For more information, visit - https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilters.html | `string` | `"arn:aws:lambda:us-east-1:123456789000:function:TestLambda"` | no |
| <a name="input_log_group_pattern"></a> [log\_group\_pattern](#input\_log\_group\_pattern) | Enter regex for matching logGroups | `string` | `"Test"` | no |
| <a name="input_log_group_tags"></a> [log\_group\_tags](#input\_log\_group\_tags) | Enter comma separated keyvalue pairs for filtering logGroups using tags. Ex KeyName1=string,KeyName2=string. This is optional leave it blank if tag based filtering is not needed. | `list(string)` | `[]` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | Enter AWS IAM Role arn in case the destination is Kinesis Firehose stream. | `string` | `""` | no |
| <a name="input_use_existing_logs"></a> [use\_existing\_logs](#input\_use\_existing\_logs) | Select true for subscribing existing logs | `string` | `"true"` | no |

## Outputs

No outputs.
