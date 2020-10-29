# Sumo Logic to Jira Service Desk Webhook

## Purpose

The [Sumo Logic to Jira Service Desk Webhook](https://help.sumologic.com/Beta/Webhook_Connections_for_Jira/Webhook_Connection_for_Jira_Service_Desk) configures a Webhook in Sumo Logic to send events to Jira Service Desk.

## Requirements

* Terraform >= 0.12.26
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

### Sumo Logic to Jira Service Desk Webhook
```shell
module "sumologic-jira-service-desk-webhook" {
  source = "git@github.com:SumoLogic/terraform-sumologic-integrations//atlassian/webhooks/sumologic_jira_service_desk"
  jira_servicedesk_url        = "<JIRA_SERVICE_DESK_URL>"
  jira_servicedesk_issuetype  = "Bug"
  jira_servicedesk_priority   = "3"
  jira_servicedesk_projectkey = "<JIRA_SERVICE_DESK_PROJECT_KEY>"
  jira_servicedesk_auth       = "<JIRA_SERVICE_DESK_BASIC_AUTH>"
}
```

## Inputs for Sumo Logic to Opsgenie Webhook

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
|jira_servicedesk_url|Jira Service Desk URL|string||yes
|jira_servicedesk_issuetype|Jira Service Desk Issue Type|string|Bug|yes
|jira_servicedesk_priority|Jira Service Desk Priority|string|3|yes
|jira_servicedesk_projectkey|Jira Service Desk Project Key|string||yes
|jira_servicedesk_auth|Jira Service Desk Basic Authorization Header|string||yes