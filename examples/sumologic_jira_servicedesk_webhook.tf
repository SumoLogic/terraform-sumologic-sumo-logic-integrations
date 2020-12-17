provider "sumologic" {
  access_id   = "<SUMO_ACCESS_ID>"
  access_key  = "<SUMO_ACCESS_KEY>"
  environment = "us1"
}

# Sumo Logic to Jira Service Desk Webhook
module "sumologic-jira-service-desk-webhook" {
  source                      = "SumoLogic/sumo-logic-integrations/sumologic//atlassian/webhooks/sumologic_jira_service_desk"
  version                      = "{revision}"
  jira_servicedesk_url        = "<JIRA_SERVICE_DESK_URL>"
  jira_servicedesk_issuetype  = "Bug"
  jira_servicedesk_priority   = "3"
  jira_servicedesk_projectkey = "<JIRA_SERVICE_DESK_PROJECT_KEY>"
  jira_servicedesk_auth       = "<JIRA_SERVICE_DESK_BASIC_AUTH>"
}