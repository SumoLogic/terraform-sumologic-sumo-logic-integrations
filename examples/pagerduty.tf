provider "pagerduty" {
  token = "<PAGERDUTY_TOKEN>"
}

### Pagerduty Module
module "sumologic-jira-pagerduty-app" {
  source                                    = "SumoLogic/sumo-logic-integrations/sumologic//pagerduty"
  version                                   = "{revision}"

  sumo_access_id                            = "<SUMO_ACCESS_ID>"
  sumo_access_key                           = "<SUMO_ACCESS_KEY>"
  sumo_api_endpoint                         = "https://api.sumologic.com/api/v1/"
  collector_id                              = sumologic_collector.sumo_collector.id
  source_category                           = "Pagerduty"
  folder_id                                 = sumologic_folder.folder.id
  pagerduty_services_pagerduty_webhooks     = ["<PG_SERVICE1>","PG_SERVICE2"]
  app_version                               = "1.0"
}