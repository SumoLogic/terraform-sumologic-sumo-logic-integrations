
module "cloudtrail_module" {
  source = "../../../cloudtrail"

  create_collector          = local.create_collector
  create_trail              = local.create_trail
  sumologic_organization_id = local.sumologic_organization_id
  wait_for_seconds          = 20

  source_details = {
    source_name     = local.cloudtrail_source_details.source_name
    source_category = local.cloudtrail_source_details.source_category
    description     = local.cloudtrail_source_details.description
    collector_id    = local.sumologic_existing_collector_id
    bucket_details = {
      create_bucket        = true
      bucket_name          = local.cloudtrail_source_details.bucket_details.bucket_name
      path_expression      = local.cloudtrail_source_details.bucket_details.path_expression
      force_destroy_bucket = false
    }
    paused               = false
    scan_interval        = 60000
    sumo_account_id      = local.sumo_account_id
    cutoff_relative_time = "-1d"
    fields               = local.cloudtrail_fields
    iam_details = {
      create_iam_role = true
      iam_role_arn    = null
    }
    sns_topic_details = {
      create_sns_topic = true
      sns_topic_arn = null
    }
  }
}