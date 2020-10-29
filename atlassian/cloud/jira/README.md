# Jira Cloud

## Purpose

This module installs [Sumo Logic Jira Cloud application](https://help.sumologic.com/07Sumo-Logic-Apps/08App_Development/Jira_Cloud) in Sumo Logic and configures a Webhook in Jira Cloud to send events to Sumo Logic.

## Requirements

* Terraform >= 0.12.26
* Null >= 2.1
* Jira >= 0.1.12

## Module Declaration

This module requires Sumo Logic collector Id and Folder id as explained [here](https://github.com/SumoLogic/terraform-sumologic-integrations#prerequisites-for-using-modules).

### JIRA Cloud Provider

```shell
provider "jira" {
  url      = "<JIRA_CLOUD_URL>"
  user     = "<JIRA_CLOUD_USERNAME>"
  password = "<JIRA_CLOUD_ACCESSKEY>"
}
```
### Jira Cloud

```shell
module "sumologic-jira-cloud-app" {
  source            = "git@github.com:SumoLogic/terraform-sumologic-integrations//atlassian/cloud/jira"
  sumo_access_id    = "<SUMO_ACCESS_ID>"
  sumo_access_key   = "<SUMO_ACCESS_KEY>"
  sumo_api_endpoint = "https://api.sumologic.com/api/v1/"
  collector_id      = sumologic_collector.sumo_collector.id
  source_category   = "Atlassian/Cloud/Jira"
  folder_id         = sumologic_folder.folder.id
  jira_cloud_jql    = ""                                           # Optional
  jira_cloud_events = ["jira:issue_created", "jira:issue_updated"] # Optional. By default all events are configured.
  app_version       = "1.0"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
|sumo_access_id|[Sumo Logic Access ID](https://help.sumologic.com/Manage/Security/Access-Keys)|string||yes
|sumo_access_key|[Sumo Logic Access Key](https://help.sumologic.com/Manage/Security/Access-Keys)|string||yes
|sumo_api_endpoint|[Sumo Logic API Endpoint](https://help.sumologic.com/APIs/General-API-Information/Sumo-Logic-Endpoints-and-Firewall-Security)|string|https://api.sumologic.com/api/v1/|yes
|collector_id|Sumo Logic Collector ID|string||yes
|folder_id|Sumo Logic Folder ID|string||yes
|source_category|Jira Cloud Source Category|string|Atlassian/Cloud/Jira|yes
|jira_cloud_jql|Jira Cloud Query Language expression|string||no
|jira_cloud_events|Jira Cloud Events to Push to Sumo Logic|list|List of all the Jira Cloud Events|yes
|app_version|The app_version input parameter can be used to install a new copy of the app. When the app_version field is changed, it will force Terraform to install a new app folder with the current timestamp.|String|1.0|no