# JIRA Server Provider
provider "jira" {
  alias    = "server"
  url      = "<JIRA_SERVER_URL>"
  user     = "<JIRA_SERVER_USERNAME>"
  password = "<JIRA_SERVER_PASSWORD>"
}

# Jira Server
module "sumologic-jira-server-app" {
  source = "git@github.com:SumoLogic/terraform-sumologic-integrations//atlassian/server/jira"
  providers = {
    jira = jira.server
  }
  sumo_access_id     = "<SUMO_ACCESS_ID>"
  sumo_access_key    = "<SUMO_ACCESS_KEY>"
  sumo_api_endpoint  = "https://api.sumologic.com/api/v1/"
  collector_id       = sumologic_collector.sumo_collector.id
  source_category    = "Atlassian/Jira/Events"
  folder_id          = sumologic_folder.folder.id
  jira_server_jql    = ""
  jira_server_events = ["jira:issue_created", "jira:issue_updated"] # By default all events are configured.
  app_version            = "1.0"
}