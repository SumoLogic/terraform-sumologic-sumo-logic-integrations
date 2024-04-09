## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.43.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.28.3, < 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.43.0 |
| <a name="provider_sumologic"></a> [sumologic](#provider\_sumologic) | 2.28.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudtrail_module"></a> [cloudtrail\_module](#module\_cloudtrail\_module) | ../../../cloudtrail | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [sumologic_caller_identity.current](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sumo_aws_account_id"></a> [sumo\_aws\_account\_id](#input\_sumo\_aws\_account\_id) | Please provide Sumo's AWS account ID | `string` | n/a | yes |
| <a name="input_sumologic_access_id"></a> [sumologic\_access\_id](#input\_sumologic\_access\_id) | Please provide access ID for your Sumo Account | `string` | n/a | yes |
| <a name="input_sumologic_access_key"></a> [sumologic\_access\_key](#input\_sumologic\_access\_key) | Please provide access key for your Sumo Account | `string` | n/a | yes |
| <a name="input_sumologic_collector_id"></a> [sumologic\_collector\_id](#input\_sumologic\_collector\_id) | Please provide Sumo Collector ID | `string` | n/a | yes |
| <a name="input_sumologic_environment"></a> [sumologic\_environment](#input\_sumologic\_environment) | Please provide SumoLogic deployment environment | `string` | n/a | yes |
| <a name="input_sumologic_organization_id"></a> [sumologic\_organization\_id](#input\_sumologic\_organization\_id) | Appears on the Account Overview page that displays information about your Sumo Logic organization. Used for IAM Role in Sumo Logic AWS Sources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_account_id"></a> [aws\_account\_id](#output\_aws\_account\_id) | n/a |
| <a name="output_aws_region_data"></a> [aws\_region\_data](#output\_aws\_region\_data) | n/a |
| <a name="output_sumologic_env"></a> [sumologic\_env](#output\_sumologic\_env) | n/a |
