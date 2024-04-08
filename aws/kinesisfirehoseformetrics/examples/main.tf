module "kinesis_firehose_for_metrics_source_module" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/kinesisfirehoseformetrics"

  create_collector          = true
  sumologic_organization_id = var.sumologic_organization_id
  wait_for_seconds          = 20

  source_details = {
    source_name         = "<Source-Name>"
    source_category     = "<Source-Category>"
    description         = "<Source-Description>"
    collector_id        = null
    limit_to_namespaces = []
    sumo_account_id     = 926226587429
    fields              = {}
    iam_details = {
      create_iam_role = true
      iam_role_arn    = null
    }
  }

  create_bucket = true
  bucket_details = {
    bucket_name          = "<AWS-S3-bucket>"
    force_destroy_bucket = false
  }
}