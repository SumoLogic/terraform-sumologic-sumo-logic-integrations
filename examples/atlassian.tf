# Atlassian App
module "sumologic-jira-atlassian-app" {
  source                               = "SumoLogic/sumo-logic-integrations/sumologic//atlassian/cloud/atlassian"
  version                              = "{revision}"

  sumo_access_id                       = "<SUMO_ACCESS_ID>"
  sumo_access_key                      = "<SUMO_ACCESS_KEY>"
  sumo_api_endpoint                    = "https://api.sumologic.com/api/v1/"
  opsgenie_source_category             = "Atlassian/Opsgenie"
  jira_server_webhooks_source_category = "Atlassian/Jira/Events"
  jira_cloud_source_category           = "Atlassian/Jira/Cloud"
  bitbucket_source_category            = "Atlassian/Bitbucket"
  folder_id                            = sumologic_folder.folder.id
  app_version                              = "1.0"
}