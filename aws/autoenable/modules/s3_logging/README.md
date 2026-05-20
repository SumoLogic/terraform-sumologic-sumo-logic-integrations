# SumoLogic-S3-loggingAuto-Enable

This module is used to create AWS resources to automatically enable logging for newly created and/or existing AWS resources. Features include:
- Create AWS Lambda function to automatically enable S3 access logs for S3 buckets, VPC flow logs for VPCs/Subnets/Network Interfaces, and access logs for Application/Classic Load Balancers
- Create AWS CloudWatch Event Rules to trigger Lambda function when new AWS resources are created (S3 buckets, VPCs, Load Balancers)
- Create AWS IAM role with appropriate permissions for Lambda function to manage logging configurations
- Support for filtering AWS resources using regular expressions to selectively enable logging
- Configurable options to enable logging for new resources only, existing resources only, or both
- Support for custom S3 bucket and prefix for storing logs
- Option to automatically remove logging configurations when stack is deleted
- Support for multiple AWS resource types: S3 buckets, VPC Flow Logs, Application Load Balancers (ALB), and Classic Load Balancers (ELB)

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.16.2, < 7.0.0 |
| <a name="provider_lambda-invoke-extension"></a> [lambda-invoke-extension](#provider\_lambda-invoke-extension) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.auto_enable_alb_log_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.auto_enable_elb_log_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.auto_enable_s3_log_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.auto_enable_vpc_log_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.alb_lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.elb_lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.s3_lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.vpc_lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.sumo_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.sumo_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.enable_existing_aws_resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.enable_new_aws_resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.alb_events_invoke_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.elb_events_invoke_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.s3_events_invoke_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.vpc_events_invoke_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| lambda-invoke-extension_lambda_invoke_extension_action.enable_logging | resource |
| [random_string.stack_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_enable_logging"></a> [auto\_enable\_logging](#input\_auto\_enable\_logging) | S3 - To Enable S3 Audit Logging for new S3 buckets. VPC - To Enable VPC flow logs for new VPC, Subnets and Network Interfaces. ALB - To Enable S3 Logging for new Application Load Balancer. ELB - To Enable S3 logging for new Classic Load Balancer | `string` | n/a | yes |
| <a name="input_auto_enable_resource_options"></a> [auto\_enable\_resource\_options](#input\_auto\_enable\_resource\_options) | New - Automatically enables S3 logging for newly created AWS resources to send logs to S3 Buckets. Existing - Automatically enables S3 logging for existing AWS resources. Both - Automatically enables S3 logging for new and existing AWS resources. None - Skips Automatic S3 Logging enable for AWS resources. | `string` | `"Both"` | no |
| <a name="input_aws_resource_tags"></a> [aws\_resource\_tags](#input\_aws\_resource\_tags) | Map of tags to apply to all AWS resources provisioned through the Module | `map(string)` | `{}` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Provide an Existing bucket Name. | `string` | n/a | yes |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | Provide an bucket prefix. | `string` | `""` | no |
| <a name="input_filter_expression"></a> [filter\_expression](#input\_filter\_expression) | Provide regular expression for matching aws resources. For eg;- 'InstanceType': 't1.micro.*?'\|'name': 'Test.*?']\|'stageName': 'prod.*?'\|'FunctionName': 'Test.*?'\|TableName.*?\|'LoadBalancerName': 'Test.*?'\|'DBClusterIdentifier': 'Test.*?'\|'DBInstanceIdentifier': 'Test.*?' | `string` | `""` | no |
| <a name="input_remove_on_delete_stack"></a> [remove\_on\_delete\_stack](#input\_remove\_on\_delete\_stack) | True - To remove S3 logging or Vpc flow logs. False - To keep the S3 logging. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_enable_existing_aws_resources_lambda_arn"></a> [enable\_existing\_aws\_resources\_lambda\_arn](#output\_enable\_existing\_aws\_resources\_lambda\_arn) | Lambda Function ARN for Existing AWS Resources |
| <a name="output_enable_new_aws_resources_lambda_arn"></a> [enable\_new\_aws\_resources\_lambda\_arn](#output\_enable\_new\_aws\_resources\_lambda\_arn) | Lambda Function ARN for New AWS Resources |
