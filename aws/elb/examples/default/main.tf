resource "random_string" "aws_random" {
  length  = 10
  upper   = false
  special = false
}

module "lb_module" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/elb"

  create_collector          = true
  sumologic_organization_id = var.sumologic_organization_id
  wait_for_seconds          = 20
  aws_resource_tags = local.aws_resource_tags

  source_details = {
    source_name     = "Application Load Balancer Logs (Region)"
    source_category = "aws/observability/alb/logs"
    description     = "This source is created using Sumo Logic terraform AWS Observability module to collect AWS Application Load Balancer logs."
    collector_id    = null
    bucket_details = {
      create_bucket        = true
      bucket_name          = local.bucket_name
      path_expression      = local.path_expression
      force_destroy_bucket = false
    }
    paused               = false
    scan_interval        = 60000
    sumo_account_id      = 926226587429
    cutoff_relative_time = "-1d"
    fields               = {}
    iam_details = {
      create_iam_role = true
      iam_role_arn    = ""
    }
    sns_topic_details = {
      create_sns_topic = true
      sns_topic_arn    = ""
    }
  }
  auto_enable_access_logs = "Both"
  app_semantic_version = "1.0.10"
  auto_enable_access_logs_options = {
    filter                 = "'Type': 'application'|'type': 'application'"
    remove_on_delete_stack = true
  }
}
