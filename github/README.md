# Github

## Purpose

This module installs [Sumo Logic Github application](https://help.sumologic.com/07Sumo-Logic-Apps/08App_Development/Github) in Sumo Logic and configures Webhooks in Github to send events to Sumo Logic.

Note: This module doesn't create the field required by Github App, please configure the field as defined [here](https://help.sumologic.com/07Sumo-Logic-Apps/08App_Development/GitHub/01Collect-Logs-for-the-GitHub-App#enable-github-event-tagging-at-sumo-logic).

## Requirements

* [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
* Null >= 2.1
* Github >= 2.8

## Module Declaration

This module requires Sumo Logic collector Id and Folder id as explained [here](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations#prerequisites-for-using-modules).

### Github Provider
```shell
provider "github" {
  token = "<GITHUB_TOKEN>"
  organization = "<GITHUB_ORGANIZATION"
}
```

### Github Module
```shell
module "sumologic-jira-github-app" {
  source                      = "SumoLogic/sumo-logic-integrations/sumologic//github"
  version                     = "{revision}"

  sumo_access_id              = "<SUMO_ACCESS_ID>"
  sumo_access_key             = "<SUMO_ACCESS_KEY>"
  sumo_api_endpoint           = "https://api.sumologic.com/api/v1/"
  collector_id                = sumologic_collector.sumo_collector.id
  source_category             = "Github"
  folder_id                   = sumologic_folder.folder.id
  github_repo_webhook_create  = "true"
  github_org_webhook_create   = "true"
  github_repository_names     = ["<GITHUB_REPOSITORY_NAME1>", "<GITHUB_REPOSITORY_NAME2"]
  github_repo_events          = ["create","delete","fork"] # By default all events are configured.
  github_org_events           = ["create","delete","fork"] # By default all events are configured.
  app_version                 = "1.0"
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
|source_category|Github Source Category|string|Github|yes
|github_token|[Github Token.](https://github.com/settings/tokens)|string| |yes
|github_repo_webhook_create|Create webhooks at repo level. Default "true".|string|true|no
|github_org_webhook_create|Create webhooks at org level. Default "false".|string|false|no
|github_organization|Organization Name.|string| |yes
|github_repository_names|List of repository names for which webhooks need to be created. Example, ["repo1","repo2"]|list| |yes
|github_repo_events|List of repository [events](https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads) which should be sent to Sumo Logic. Example, ["create","delete","fork"]|list|List of all the Github Repo Events|yes
|github_org_events|List of organization level [events](https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads) which should be sent to Sumo Logic. Example, ["create","delete","fork"]|string|List of all the Github Org Events|yes
|app_version|The app_version input parameter can be used to install a new copy of the app. When the app_version field is changed, it will force Terraform to install a new app folder with the current timestamp.|String|1.0|no