# CloudTrail Apps
module "sumologic-cloudtrail-apps" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/cloudtrail"
  version                              = "{revision}"

  sumo_access_id                       = "<SUMO_ACCESS_ID>"
  sumo_access_key                      = "<SUMO_ACCESS_KEY>"
  sumo_external_id                     = "<SUMO_EXTERNAL_ID>"
  aws_resource_name                    = "sumo-logic-terraform-cloudtrail"
  sumo_api_endpoint                    = "https://api.sumologic.com/api/v1/"
  sumo_collector_name                  = "sumo-logic-terraform-cloudtrail"
  sumo_source_name                     = "sumo-logic-terraform-cloudtrail"
  sumo_source_category                 = "AWS/CloudTrail"
  sumo_aws_account_id                  = "926226587429"
  folder_id                            = sumologic_folder.folder.id
  app_version                          = "1.0"
}