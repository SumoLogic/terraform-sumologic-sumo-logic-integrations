# Bitbucket

## Purpose

This module installs [Sumo Logic Bitbucket application](https://help.sumologic.com/07Sumo-Logic-Apps/08App_Development/Bitbucket) in Sumo Logic and configures Webhooks in Bitbucket to send events to Sumo Logic.

## Requirements

* [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
* Null >= 2.1
* Bitbucket >= 1.2

## Module Declaration

This module requires Sumo Logic collector Id and Folder id as explained [here](https://github.com/SumoLogic/terraform-sumologic-integrations#prerequisites-for-using-modules).

### BitBucket Provider
```shell
provider "bitbucket" {
  username = "<BITBUCKET_USERNAME>"
  password = "<BITBUCKET_PASSWORD_OR_APP_PASSWORD"
}
```

### Bitbucket Module
```shell
module "sumologic-jira-bitbucket-app" {
  source                 = "git@github.com:SumoLogic/terraform-sumologic-integrations//atlassian/cloud/bitbucket"
  sumo_access_id         = "<SUMO_ACCESS_ID>"
  sumo_access_key        = "<SUMO_ACCESS_KEY>"
  sumo_api_endpoint      = "https://api.sumologic.com/api/v1/"
  collector_id           = sumologic_collector.sumo_collector.id
  source_category        = "Atlassian/Bitbucket"
  folder_id              = sumologic_folder.folder.id
  bitbucket_cloud_owner  = "<BITBUCKET_OWNER_NAME_OR_TEAM_NAME>"
  bitbucket_cloud_desc   = "Send events to Sumo Logic"
  bitbucket_cloud_repos  = ["<BITBUCKET_REPOSITORY_NAME1>", "<BITBUCKET_REPOSITORY_NAME2"]
  bitbucket_cloud_events = ["repo:push", "repo:fork", "repo:updated", "repo:commit_comment_created"] # By default all events are configured.
  app_version            = "1.0"
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
|source_category|Bitbucket Source Category|string|Atlassian/Bitbucket|yes
|bitbucket_cloud_owner|Bitbucket Owner Name or Team Name having access to reposiitories.|string||yes
|bitbucket_cloud_desc|Bitbucket Webhook Description|string|Send events to Sumo Logic|yes
|bitbucket_cloud_repos|Bitbucket Repository Names for which the Webhooks need to be configured.|list||yes
|bitbucket_cloud_events|Bitbucket Events to Push to Sumo Logic|list|List of all the Bitbucket Cloud Events|yes
|app_version|The app_version input parameter can be used to install a new copy of the app. When the app_version field is changed, it will force Terraform to install a new app folder with the current timestamp.|String|1.0|no