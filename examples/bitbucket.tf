# BitBucket Provider
provider "bitbucket" {
  username = "<BITBUCKET_USERNAME>"
  password = "<BITBUCKET_PASSWORD_OR_APP_PASSWORD"
}

# Bitbucket
module "sumologic-jira-bitbucket-app" {
  source                 = "SumoLogic/sumo-logic-integrations/sumologic//atlassian/cloud/bitbucket"
  version                = "{revision}"

  sumo_access_id         = "<SUMO_ACCESS_ID>"
  sumo_access_key        = "<SUMO_ACCESS_KEY>"
  sumo_api_endpoint      = "https://api.sumologic.com/api/v1/"
  collector_id           = sumologic_collector.sumo_collector.id
  source_category        = "Atlassian/Bitbucket"
  folder_id              = sumologic_folder.folder.id
  bitbucket_cloud_owner  = "<BITBUCKET_OWNER_NAME_OR_TEAM_NAME"
  bitbucket_cloud_desc   = "Send events to Sumo Logic" # Default configured
  bitbucket_cloud_repos  = ["<BITBUCKET_REPOSITORY_NAME1>", "<BITBUCKET_REPOSITORY_NAME2>"]
  bitbucket_cloud_events = ["repo:push", "repo:fork", "repo:updated", "repo:commit_comment_created"] # By default all events are configured.
  app_version                = "1.0"
}