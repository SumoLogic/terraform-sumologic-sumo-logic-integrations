# Pagerduty

## Purpose

This module installs [Sumo Logic Pagerduty V2 application](https://help.sumologic.com/07Sumo-Logic-Apps/08App_Development/PagerDuty_V2) in Sumo Logic and configures Webhooks in Pagerduty to send events to Sumo Logic.

## Requirements

* [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
* Null >= 2.1
* Pagerduty >= 1.2

## Module Declaration

This module requires Sumo Logic collector Id and Folder id as explained [here](https://github.com/SumoLogic/terraform-sumologic-integrations#prerequisites-for-using-modules).

### Pagerduty Provider
```shell
provider "pagerduty" {
  token = "<PAGERDUTY_TOKEN>"
}
```

### Pagerduty Module
```shell
module "sumologic-jira-pagerduty-app" {
  source                                  = "SumoLogic/integrations/sumologic//pagerduty"
  version                                 = "{revision}"

  sumo_access_id                          = "<SUMO_ACCESS_ID>"
  sumo_access_key                         = "<SUMO_ACCESS_KEY>"
  sumo_api_endpoint                       = "https://api.sumologic.com/api/v1/"
  collector_id                            = sumologic_collector.sumo_collector.id
  source_category                         = "Pagerduty"
  folder_id                               = sumologic_folder.folder.id
  pagerduty_services_pagerduty_webhooks   = ["SERVICE_ID1","SERVICE_ID2"] # By default all events are configured.
  app_version                             = "1.0"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
|sumo_access_id|[Sumo Logic Access ID](https://help.sumologic.com/Manage/Security/Access-Keys)|string| |yes
|sumo_access_key|[Sumo Logic Access Key](https://help.sumologic.com/Manage/Security/Access-Keys)|string| |yes
|sumo_api_endpoint|[Sumo Logic API Endpoint](https://help.sumologic.com/APIs/General-API-Information/Sumo-Logic-Endpoints-and-Firewall-Security)|string|https://api.sumologic.com/api/v1/|yes
|collector_id|Sumo Logic Collector ID|string| |yes
|folder_id|Sumo Logic Folder ID|string| |yes
|source_category|Pagerduty Source Category|string|Pagerduty|yes
|pagerduty_services_pagerduty_webhooks|List of Pagerduty Service IDs. Example, ["P1QWK8J","PK9FKW3"]. You can get these from the URL after opening a specific service in Pagerduty. These are used for Pagerduty to Sumo Logic webhooks.|list| |yes
|app_version|The app_version input parameter can be used to install a new copy of the app. When the app_version field is changed, it will force Terraform to install a new app folder with the current timestamp.|String|1.0|no