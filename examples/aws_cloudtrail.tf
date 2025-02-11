# CloudTrail Apps
module "sumologic-cloudtrail-apps" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/cloudtrail"

  create_collector          = true
  create_trail              = true
  sumologic_organization_id = "0000000000123456"
  collector_details = {
    "collector_name" = "Test Updated Cloudtrail Module One",
    "description"    = "This is a new description.",
    "fields" = {
      "TestCollector" = "MyValue"
    }
  }
  source_details = {
    "source_name"     = "My Test Source Another",
    "source_category" = "Labs/test/cloudtrail",
    "description"     = "This source is ceated a.",
    "bucket_details" = {
      "create_bucket"        = false,
      "bucket_name"          = "YourS3BucketName",
      "path_expression"      = "AWSLogs/*/CloudTrail/us-east-1/*",
      "force_destroy_bucket" = true
    },
    "paused"               = false,
    "scan_interval"        = 60000,
    "cutoff_relative_time" = "-1d",
    "fields" = {
      "TestCollector" = "MyValue"
    },
    "sumo_account_id" = "926226587429",
    "collector_id"    = "",
    "iam_details" = {
      "create_iam_role" = true,
      "iam_role_arn"    = ""
    }
    "sns_topic_details" = {
      "create_sns_topic" = true,
      "sns_topic_arn"    = ""
    }
  }
}