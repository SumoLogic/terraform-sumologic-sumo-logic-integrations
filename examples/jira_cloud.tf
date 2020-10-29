# JIRA Cloud Provider
provider "jira" {
  url      = "<JIRA_CLOUD_URL>"
  user     = "<JIRA_CLOUD_USERNAME>"
  password = "<JIRA_CLOUD_ACCESSKEY>"
}

# Jira Cloud
module "sumologic-jira-cloud-app" {
  source            = "git@github.com:SumoLogic/terraform-sumologic-integrations//atlassian/cloud/jira"
  sumo_access_id    = "<SUMO_ACCESS_ID>"
  sumo_access_key   = "<SUMO_ACCESS_KEY>"
  sumo_api_endpoint = "https://api.sumologic.com/api/v1/"
  collector_id      = sumologic_collector.sumo_atlassian_collector.id
  source_category   = "Atlassian/Cloud/Jira"
  folder_id         = sumologic_folder.folder.id
  jira_cloud_jql    = ""
  jira_cloud_events = ["jira:issue_created", "jira:issue_updated"] # By default all events are configured.
  app_version           = "1.0"
}