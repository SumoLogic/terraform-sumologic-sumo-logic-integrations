# SumoLogic-GCP-Logging


This module is used to create GCP and Sumo Logic resources to collect logs from the [Cloud Logging] service in GCP.
Features include:
- Create a Sumologic source and a collector
- Create a PubSub Topic and a Subscription
- Create a Cloud Logging Sink
- Assign the pubsub.publisher role to the Cloud Logging service account

For examples please check the [example] folder.

<!-- Links -->
[Cloud Logging]:https://cloud.google.com/logging
[example]:(example)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.0 |
| <a name="requirement_sumologic"></a> [sumologic](#requirement\_sumologic) | >= 2.11 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.0 |
| <a name="provider_sumologic"></a> [sumologic](#provider\_sumologic) | >= 2.11 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_logging_project_sink.sumologic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_project_iam_binding.sumologic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_pubsub_subscription.sumologic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_topic.sumologic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [sumologic_collector.this](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/collector) | resource |
| [sumologic_gcp_source.this](https://registry.terraform.io/providers/SumoLogic/sumologic/latest/docs/resources/gcp_source) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gcp_project"></a> [gcp\_project](#input\_gcp\_project) | GCP project ID. | `string` | n/a | yes |
| <a name="input_logging_sink_filter"></a> [logging\_sink\_filter](#input\_logging\_sink\_filter) | Logging filter for the GCP sink. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Names that will be assigned to resources. | `string` | n/a | yes |
| <a name="input_sumologic_category"></a> [sumologic\_category](#input\_sumologic\_category) | The category description for the collector/source. | `string` | `"gcp"` | no |
| <a name="input_sumologic_collector_fields"></a> [sumologic\_collector\_fields](#input\_sumologic\_collector\_fields) | A Map containing key/value pairs. | `map(any)` | `null` | no |
| <a name="input_sumologic_collector_name"></a> [sumologic\_collector\_name](#input\_sumologic\_collector\_name) | Name for the collector. | `string` | `null` | no |
| <a name="input_sumologic_collector_timezone"></a> [sumologic\_collector\_timezone](#input\_sumologic\_collector\_timezone) | The time zone to use for this collector. | `string` | `null` | no |
| <a name="input_sumologic_description"></a> [sumologic\_description](#input\_sumologic\_description) | The description of the created resources collector/source. | `string` | `null` | no |
| <a name="input_sumologic_source_name"></a> [sumologic\_source\_name](#input\_sumologic\_source\_name) | Name for the GCP source. | `string` | `null` | no |

## Outputs

No outputs.
