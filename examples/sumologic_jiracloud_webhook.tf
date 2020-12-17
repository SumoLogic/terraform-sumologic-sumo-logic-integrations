provider "sumologic" {
  access_id   = "<SUMO_ACCESS_ID>"
  access_key  = "<SUMO_ACCESS_KEY>"
  environment = "us1"
}

# Sumo Logic to Jira Cloud Webhook
module "sumologic-jira-cloud-webhook" {
  source                = "SumoLogic/sumo-logic-integrations/sumologic//atlassian/webhooks/sumologic_jira_cloud"
  version               = "{revision}"

  jira_cloud_url        = "<JIRA_CLOUD_URL>"
  jira_cloud_issuetype  = "Bug"
  jira_cloud_priority   = "3"
  jira_cloud_projectkey = "<JIRA_CLOUD_PROJECT_KEY>"
  jira_cloud_auth       = "<JIRA_CLOUD_BASIC_AUTH>"
}