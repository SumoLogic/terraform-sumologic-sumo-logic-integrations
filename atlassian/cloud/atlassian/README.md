# Atlassian

## Purpose

This module installs [Sumo Logic Atlassian application](https://help.sumologic.com/07Sumo-Logic-Apps/08App_Development/Atlassian) in Sumo Logic.

## Requirements

* [Terraform](https://www.terraform.io/downloads.html) >= 1.5.7
* Null >= 2.1

## Module Declaration

This module requires Sumo Logic collector Id and Folder id as explained [here](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations#prerequisites-for-using-modules).

```shell
module "sumologic-jira-atlassian-app" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//atlassian/cloud/atlassian"
  sumo_access_id                       = "<SUMO_ACCESS_ID>"
  sumo_access_key                      = "<SUMO_ACCESS_KEY>"
  sumo_api_endpoint                    = "https://api.sumologic.com/api/v1/"
  opsgenie_source_category             = "Atlassian/Opsgenie"
  jira_server_webhooks_source_category = "Atlassian/Jira/Events"
  jira_cloud_source_category           = "Atlassian/Jira/Cloud"
  bitbucket_source_category            = "Atlassian/Bitbucket"
  folder_id                            = sumologic_folder.folder.id
  app_version                          = "1.0"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
|sumo_access_id|[Sumo Logic Access ID](https://help.sumologic.com/Manage/Security/Access-Keys)|string||yes
|sumo_access_key|[Sumo Logic Access Key](https://help.sumologic.com/Manage/Security/Access-Keys)|string||yes
|sumo_api_endpoint|[Sumo Logic API Endpoint](https://help.sumologic.com/APIs/General-API-Information/Sumo-Logic-Endpoints-and-Firewall-Security)|string|https://api.sumologic.com/api/v1/|yes
|folder_id|Sumo Logic Folder ID|string||yes
|opsgenie_source_category|Opsgenie Source Category|string|Atlassian/Opsgenie|yes
|jira_cloud_source_category|Jira Cloud Source Category|string|Atlassian/Jira/Cloud|yes
|jira_server_webhooks_source_category|Jira Server Source Category|string|Atlassian/Jira/Events|yes
|bitbucket_source_category|Bitbucket Source Category|string|Atlassian/Bitbucket|yes
|app_version|The app_version input parameter can be used to install a new copy of the app. When the app_version field is changed, it will force Terraform to install a new app folder with the current timestamp.|String|1.0|no