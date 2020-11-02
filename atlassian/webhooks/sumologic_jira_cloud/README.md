# Sumo Logic to Jira Cloud

## Purpose

The [Sumo Logic to Jira Cloud Webhook](https://help.sumologic.com/Beta/Webhook_Connections_for_Jira/Webhook_Connection_for_Jira_Cloud) configures a Webhook in Sumo Logic to send events to Jira Cloud.

## Requirements

* [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
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

# Sumo Logic to Jira Cloud Webhook
```shell
module "sumologic-jira-cloud-webhook" {
  source                = "SumoLogic/integrations/sumologic//atlassian/webhooks/sumologic_jira_cloud"
  version               = "{revision}"

  jira_cloud_url        = "<JIRA_CLOUD_URL>"
  jira_cloud_issuetype  = "Bug"
  jira_cloud_priority   = "3"
  jira_cloud_projectkey = "<JIRA_CLOUD_PROJECT_KEY>"
  jira_cloud_auth       = "<JIRA_CLOUD_BASIC_AUTH>"
}
```

## Inputs for Sumo Logic to Opsgenie Webhook

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
|jira_cloud_url|Jira Cloud URL|string||yes
|jira_cloud_issuetype|Jira Cloud Issue Type|string|Bug|yes
|jira_cloud_priority|Jira Cloud Priority|string|3|yes
|jira_cloud_projectkey|Jira Cloud Project Key|string||yes
|jira_cloud_auth|Jira Cloud Basic Authorization Header|string||yes