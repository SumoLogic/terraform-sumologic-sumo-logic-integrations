# SumoLogic

This module is used to create Sumo Logic resource. Features include
- Metric Rules
- Field Extraction Rules
- Fields
- App content
- Monitors

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 2.1 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.31.3, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | >= 2.1 |
| <a name="provider_sumologic"></a> [sumologic](#provider\_sumologic) | >= 2.31.3, < 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_SumoLogicMonitors"></a> [SumoLogicMonitors](#module\_SumoLogicMonitors) | SumoLogic/sumo-logic-monitor/sumologic | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.MetricRules](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [sumologic_content.SumoLogicApps](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/content) | resource |
| [sumologic_field.SumoLogicFields](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/field) | resource |
| [sumologic_field_extraction_rule.SumoLogicFieldExtractionRules](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/field_extraction_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_id"></a> [access\_id](#input\_access\_id) | Sumo Logic Access ID. Visit https://help.sumologic.com/Manage/Security/Access-Keys#Create_an_access_key | `string` | n/a | yes |
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | Sumo Logic Access Key. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Enter au, ca, de, eu, fed, in, jp, kr, us1 or us2. Visit https://help.sumologic.com/APIs/General-API-Information/Sumo-Logic-Endpoints-and-Firewall-Security | `string` | n/a | yes |
| <a name="input_managed_apps"></a> [managed\_apps](#input\_managed\_apps) | The list of Application to manage within the Sumo Logic AWS Observability Solution | <pre>map(object({<br/>    folder_id    = string<br/>    content_json = string<br/>  }))</pre> | `{}` | no |
| <a name="input_managed_field_extraction_rules"></a> [managed\_field\_extraction\_rules](#input\_managed\_field\_extraction\_rules) | The list of Field Extraction Rules to manage within the Sumo Logic AWS Observability Solution | <pre>map(object({<br/>    name             = string<br/>    parse_expression = string<br/>    scope            = string<br/>    enabled          = bool<br/>  }))</pre> | `{}` | no |
| <a name="input_managed_fields"></a> [managed\_fields](#input\_managed\_fields) | The list of Fields to manage within the Sumo Logic AWS Observability Solution | <pre>map(object({<br/>    field_name = string<br/>    data_type  = string<br/>    state      = bool<br/>  }))</pre> | `{}` | no |
| <a name="input_managed_metric_rules"></a> [managed\_metric\_rules](#input\_managed\_metric\_rules) | The list of metric rules to manage within the Sumo Logic AWS Observability solution. | <pre>map(object({<br/>    metric_rule_name = string<br/>    match_expression = string<br/>    sleep            = number<br/>    variables_to_extract = list(object({<br/>      name        = string<br/>      tagSequence = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_managed_monitors"></a> [managed\_monitors](#input\_managed\_monitors) | The list of Monitors to manage within the Sumo Logic AWS Observability Solution | <pre>map(object({<br/>    monitor_name         = string<br/>    monitor_description  = string<br/>    monitor_monitor_type = string<br/>    monitor_parent_id    = string<br/>    monitor_is_disabled  = bool<br/>    monitor_evaluation_delay = string<br/>    queries              = map(string)<br/>    triggers = list(object({<br/>      threshold_type   = string<br/>      threshold        = string<br/>      time_range       = string<br/>      occurrence_type  = string<br/>      trigger_source   = string<br/>      trigger_type     = string<br/>      detection_method = string<br/>    }))<br/>    connection_notifications = list(object(<br/>      {<br/>        connection_type       = string,<br/>        connection_id         = string,<br/>        payload_override      = string,<br/>        run_for_trigger_types = list(string)<br/>      }<br/>    ))<br/>    email_notifications = list(object(<br/>      {<br/>        connection_type       = string,<br/>        recipients            = list(string),<br/>        subject               = string,<br/>        time_zone             = string,<br/>        message_body          = string,<br/>        run_for_trigger_types = list(string)<br/>      }<br/>    ))<br/>    group_notifications = bool<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sumologic_content"></a> [sumologic\_content](#output\_sumologic\_content) | This output contains all the Apps. |
| <a name="output_sumologic_field"></a> [sumologic\_field](#output\_sumologic\_field) | This output contains all the fields. |
| <a name="output_sumologic_field_extraction_rule"></a> [sumologic\_field\_extraction\_rule](#output\_sumologic\_field\_extraction\_rule) | This output contains all the Field Extraction rules. |
| <a name="output_sumologic_metric_rules"></a> [sumologic\_metric\_rules](#output\_sumologic\_metric\_rules) | This output contains all the metric rules. |
