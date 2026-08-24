## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.16.2, < 7.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.1.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 3.3.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >=3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_logging_auto_enable_module"></a> [s3\_logging\_auto\_enable\_module](#module\_s3\_logging\_auto\_enable\_module) | SumoLogic/sumo-logic-integrations/sumologic//aws/autoenable/modules/s3_loggings | 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [random_string.aws_random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_enable_logging"></a> [auto\_enable\_logging](#input\_auto\_enable\_logging) | S3 - To Enable S3 Audit Logging for new S3 buckets. VPC - To Enable VPC flow logs for new VPC, Subnets and Network Interfaces. ALB - To Enable S3 Logging for new Application Load Balancer. ELB - To Enable S3 logging for new Classic Load Balancer | `string` | `"ALB"` | no |
| <a name="input_auto_enable_resource_options"></a> [auto\_enable\_resource\_options](#input\_auto\_enable\_resource\_options) | New - Automatically enables S3 logging for newly created AWS resources to send logs to S3 Buckets. Existing - Automatically enables S3 logging for existing AWS resources. Both - Automatically enables S3 logging for new and existing AWS resources. None - Skips Automatic S3 Logging enable for AWS resources. | `string` | `"Both"` | no |
| <a name="input_aws_resource_tags"></a> [aws\_resource\_tags](#input\_aws\_resource\_tags) | AWS resource tags | `map(string)` | `{}` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Provide an Existing bucket Name. | `string` | `""` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | Provide an bucket prefix. | `string` | `""` | no |
| <a name="input_filter_expression"></a> [filter\_expression](#input\_filter\_expression) | Provide regular expression for matching aws resources. For eg;- 'InstanceType': 't1.micro.*?'\|'name': 'Test.*?']\|'stageName': 'prod.*?'\|'FunctionName': 'Test.*?'\|TableName.*?\|'LoadBalancerName': 'Test.*?'\|'DBClusterIdentifier': 'Test.*?'\|'DBInstanceIdentifier': 'Test.*?' | `string` | `""` | no |
| <a name="input_remove_on_delete_stack"></a> [remove\_on\_delete\_stack](#input\_remove\_on\_delete\_stack) | True - To remove S3 logging or Vpc flow logs. False - To keep the S3 logging. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_logging_auto_enable_module"></a> [s3\_logging\_auto\_enable\_module](#output\_s3\_logging\_auto\_enable\_module) | All outputs related to Auto Enable. |
