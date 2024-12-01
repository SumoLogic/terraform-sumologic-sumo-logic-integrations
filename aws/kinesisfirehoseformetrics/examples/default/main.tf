resource "random_string" "aws_random" {
  length  = 10
  upper   = false
  special = false
}

module "kinesis_firehose_for_metrics_source_module" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/kinesisfirehoseformetrics"

  create_collector          = true
  sumologic_organization_id = var.sumologic_organization_id
  wait_for_seconds          = 20

  source_details = {
    source_name         = "Cloud Watch Metrics (Region)"
    source_category     = "aws/observability/cloudwatch/metrics"
    description         = "This source is created using Sumo Logic terraform AWS Observability module to collect AWS Cloud Watch metrics."
    collector_id        = null
    limit_to_namespaces = []
    "tag_filters": [{
      "type" = "TagFilters"
      "namespace" = "AWS/EC2"
      "tags" = ["env=prod;dev"]
    },{
      "type" = "TagFilters"
      "namespace" = "AWS/ApiGateway"
      "tags" = ["env=prod;dev"]
    },{
      "type" = "TagFilters"
      "namespace" = "AWS/ApplicationELB"
      "tags" = ["env=dev"]
    }],
    sumo_account_id     = 926226587429
    fields              = {}
    iam_details = {
      create_iam_role = true
      iam_role_arn    = null
    }
  }

  create_bucket = true
  bucket_details = {
    bucket_name          = local.bucket_name
    force_destroy_bucket = false
  }
}