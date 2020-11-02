provider "sumologic" {
  access_id   = "<SUMO_ACCESS_ID>"
  access_key  = "<SUMO_ACCESS_KEY>"
  environment = "us1"
}

# Sumo Logic to Jira Server Webhook
module "sumologic-jira-server-webhook" {
  source                 = "SumoLogic/integrations/sumologic//atlassian/webhooks/sumologic_jira_server"
  version                = "{revision}"

  jira_server_url        = "<JIRA_SERVER_URL>"
  jira_server_issuetype  = "Bug"
  jira_server_priority   = "3"
  jira_server_projectkey = "<JIRA_SERVER_PROJECT_KEY>"
  jira_server_auth       = "<JIRA_SERVER_BASIC_AUTH>"
}