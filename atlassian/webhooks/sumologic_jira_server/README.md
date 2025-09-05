# Sumo Logic to Jira Server

## Purpose

The [Sumo Logic to Jira Server Webhook](https://help.sumologic.com/Beta/Webhook_Connections_for_Jira/Webhook_Connection_for_Jira_Server) configures a Webhook in Sumo Logic to send events to Jira Server.

## Requirements

* [Terraform](https://www.terraform.io/downloads.html) >= 1.5.7
* Template >= 2.1
* Sumologic >= 2.1.0

## Module Declaration

### Sumo Logic Provider

```shell
provider "sumologic" {
  version = "~> 2.1.0"
  access_id   = "<SUMO_ACCESS_ID>"
  access_key  = "<SUMO_ACCESS_KEY>"
  environment = "us1"
}
```

### Sumo Logic to Jira Server Webhook
```shell
module "sumologic-jira-server-webhook" {
  source                 = "SumoLogic/sumo-logic-integrations/sumologic//atlassian/webhooks/sumologic_jira_server"
  version                = "{revision}"

  jira_server_url        = "<JIRA_SERVER_URL>"
  jira_server_issuetype  = "Bug"
  jira_server_priority   = "3"
  jira_server_projectkey = "<JIRA_SERVER_PROJECT_KEY>"
  jira_server_auth       = "<JIRA_SERVER_BASIC_AUTH>"
}
```

## Inputs for Sumo Logic to Opsgenie Webhook

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
|jira_server_url|Jira Server URL|string||yes
|jira_server_issuetype|Jira Server Issue Type|string|Bug|yes
|jira_server_priority|Jira Server Priority|string|3|yes
|jira_server_projectkey|Jira Server Project Key|string||yes
|jira_server_auth|Jira Server Basic Authorization Header|string||yes