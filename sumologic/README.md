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
| terraform | >= 0.13.0 |
| null | ~> 2.1 |
| sumologic | ~> 2.9.0 |

## Providers

| Name | Version |
|------|---------|
| null | ~> 2.1 |
| sumologic | ~> 2.9.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_id | Sumo Logic Access ID. Visit https://help.sumologic.com/Manage/Security/Access-Keys#Create_an_access_key | `string` | n/a | yes |
| access\_key | Sumo Logic Access Key. | `string` | n/a | yes |
| environment | Enter au, ca, de, eu, jp, us2, in, fed or us1. Visit https://help.sumologic.com/APIs/General-API-Information/Sumo-Logic-Endpoints-and-Firewall-Security | `string` | n/a | yes |
| managed\_apps | The list of Application to manage within the Sumo Logic AWS Observability Solution | <pre>map(object({<br>    folder_id    = string<br>    content_json = string<br>  }))</pre> | `{}` | no |
| managed\_field\_extraction\_rules | The list of Field Extraction Rules to manage within the Sumo Logic AWS Observability Solution | <pre>map(object({<br>    name             = string<br>    parse_expression = string<br>    scope            = string<br>    enabled          = bool<br>  }))</pre> | `{}` | no |
| managed\_fields | The list of Fields to manage within the Sumo Logic AWS Observability Solution | <pre>map(object({<br>    field_name = string<br>    data_type  = string<br>    state      = bool<br>  }))</pre> | `{}` | no |
| managed\_metric\_rules | The list of metric rules to manage within the Sumo Logic AWS Observability solution. | <pre>map(object({<br>    metric_rule_name = string<br>    match_expression = string<br>    sleep            = number<br>    variables_to_extract = list(object({<br>      name        = string<br>      tagSequence = string<br>    }))<br>  }))</pre> | `{}` | no |
| managed\_monitors | The list of Monitors to manage within the Sumo Logic AWS Observability Solution | <pre>map(object({<br>    monitor_name         = string<br>    monitor_description  = string<br>    monitor_monitor_type = string<br>    monitor_parent_id    = string<br>    monitor_is_disabled  = bool<br>    queries              = map(string)<br>    triggers = list(object({<br>      threshold_type   = string<br>      threshold        = string<br>      time_range       = string<br>      occurrence_type  = string<br>      trigger_source   = string<br>      trigger_type     = string<br>      detection_method = string<br>    }))<br>    connection_notifications = list(object(<br>      {<br>        connection_type       = string,<br>        connection_id         = string,<br>        payload_override      = string,<br>        run_for_trigger_types = list(string)<br>      }<br>    ))<br>    email_notifications = list(object(<br>      {<br>        connection_type       = string,<br>        recipients            = list(string),<br>        subject               = string,<br>        time_zone             = string,<br>        message_body          = string,<br>        run_for_trigger_types = list(string)<br>      }<br>    ))<br>    group_notifications = bool<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| sumologic\_content | This output contains all the Apps. |
| sumologic\_field | This output contains all the fields. |
| sumologic\_field\_extraction\_rule | This output contains all the Field Extraction rules. |
| sumologic\_metric\_rules | This output contains all the metric rules. |
