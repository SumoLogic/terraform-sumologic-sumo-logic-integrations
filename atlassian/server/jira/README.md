# Jira Server

## Purpose

This module installs [Sumo Logic Jira Server application](https://help.sumologic.com/07Sumo-Logic-Apps/08App_Development/Jira_Server) in Sumo Logic and configures a Webhook in Jira Server to send events to Sumo Logic.

## Requirements

* [Terraform](https://www.terraform.io/downloads.html) >= 1.5.7
* Template >= 2.1
* Null >= 2.1

## Module Declaration

This module requires Sumo Logic collector Id and Folder id as explained [here](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations#prerequisites-for-using-modules).

### JIRA Server Provider
```shell
provider "jira" {
  alias    = "server"
  url      = "<JIRA_SERVER_URL>"
  user     = "<JIRA_SERVER_USERNAME>"
  password = "<JIRA_SERVER_PASSWORD>"
}
```

### Jira Server
```shell
module "sumologic-jira-server-app" {
  source                                  = "SumoLogic/sumo-logic-integrations/sumologic//atlassian/server/jira"
  version                                 = "{revision}"

  providers = {
    jira = jira.server
  }
  sumo_access_id                          = "<SUMO_ACCESS_ID>"
  sumo_access_key                         = "<SUMO_ACCESS_KEY>"
  sumo_api_endpoint                       = "https://api.sumologic.com/api/v1/"
  collector_id                            = sumologic_collector.sumo_collector.id
  source_category                         = "Atlassian/Jira/Events"
  jira_server_access_logs_sourcecategory  = "Atlassian/Jira/Server*"
  folder_id                               = sumologic_folder.folder.id
  jira_server_jql                         = ""                                           # Optional
  jira_server_events                      = ["jira:issue_created", "jira:issue_updated"] # Optional. By default all events are configured.
  app_version                             = "1.0"
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
|source_category|Jira Server Source Category|string|Atlassian/Jira/Events|yes
|jira_server_access_logs_sourcecategory|This module configures Jira Server WebHooks and creates resources in Sumo Logic. Jira Server Logs collection needs to be configured as explained in Step 1 here. Configure the log collection and update the variable jira_server_access_logs_sourcecategory |string|"Atlassian/Jira/Server*"|yes
|jira_server_jql|Jira Server Query Language expression|string||no
|jira_server_events|Jira Server Events to Push to Sumo Logic|list|List of all the Jira Server Events|yes
|app_version|The app_version input parameter can be used to install a new copy of the app. When the app_version field is changed, it will force Terraform to install a new app folder with the current timestamp.|String|1.0|no