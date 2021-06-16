module "sumologic-elb" {
  source = "../aws/elb"

  create_collector          = true
  sumologic_organization_id = "0000000000123456"
  collector_details = {
    "collector_name" : "Test ELB Collector",
    "description" : "This is a new description.",
    "fields" : {
      "TestCollector" : "MyValue"
    }
  }
  source_details = {
    "source_name" : "My ELB Source",
    "source_category" : "Labs/test/elb",
    "description" : "This source is created.",
    "bucket_details" : {
      "create_bucket" : true,
      "bucket_name" : "sumologic-aws-tf-elb-module",
      "path_expression" : "*AWSLogs/*/elasticloadbalancing/us-east-1/*",
      "force_destroy_bucket" : true
    },
    "paused" : false,
    "scan_interval" : 60000,
    "cutoff_relative_time" : "-1d",
    "fields" : {
      "TestCollector" : "MyValue"
    },
    "sumo_account_id" : "926226587429",
    "collector_id" : "",
    "iam_role_arn" : "",
    "sns_topic_arn" : ""
  }
  auto_enable_access_logs = "Both"
  auto_enable_access_logs_options = {
    filter                 = ""
    remove_on_delete_stack = true
  }
}