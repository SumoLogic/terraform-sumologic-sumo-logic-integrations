## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.16.2, < 6.0.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.31.3, < 3.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch_metrics"></a> [cloudwatch\_metrics](#module\_cloudwatch\_metrics) | git::https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations.git//aws/cloudwatchmetrics | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sumologic_access_id"></a> [sumologic\_access\_id](#input\_sumologic\_access\_id) | Please provide access ID for your Sumo Account | `string` | n/a | yes |
| <a name="input_sumologic_access_key"></a> [sumologic\_access\_key](#input\_sumologic\_access\_key) | Please provide access key for your Sumo Account | `string` | n/a | yes |
| <a name="input_sumologic_environment"></a> [sumologic\_environment](#input\_sumologic\_environment) | Please provide SumoLogic deployment environment | `string` | n/a | yes |
| <a name="input_sumologic_organization_id"></a> [sumologic\_organization\_id](#input\_sumologic\_organization\_id) | Appears on the Account Overview page that displays information about your Sumo Logic organization. Used for IAM Role in Sumo Logic AWS Sources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_metrics"></a> [cloudwatch\_metrics](#output\_cloudwatch\_metrics) | All outputs related to CloudWatch metrics. |
