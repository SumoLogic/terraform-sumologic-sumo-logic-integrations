provider "github" {
  token = "<GITHUB_TOKEN>"
  organization = "<GITHUB_ORGANIZATION"
}

### Github Module
module "sumologic-jira-github-app" {
  source                      = "SumoLogic/integrations/sumologic//github"
  version                     = "{revision}"

  sumo_access_id              = "<SUMO_ACCESS_ID>"
  sumo_access_key             = "<SUMO_ACCESS_KEY>"
  sumo_api_endpoint           = "https://api.sumologic.com/api/v1/"
  collector_id                = sumologic_collector.sumo_collector.id
  source_category             = "Github"
  folder_id                   = sumologic_folder.folder.id
  github_repo_webhook_create  = "true"
  github_org_webhook_create   = "true"
  github_repository_names     = ["<GITHUB_REPOSITORY_NAME1>", "<GITHUB_REPOSITORY_NAME2"]
  github_repo_events          = ["create","delete","fork"] # By default all events are configured.
  github_org_events           = ["create","delete","fork"] # By default all events are configured.
  app_version                 = "1.0"
}