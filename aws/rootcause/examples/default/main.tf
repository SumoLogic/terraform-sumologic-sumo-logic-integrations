module "root_cause_sources_module" {
  source = "../../../rootcause"

  create_collector          = true
  sumologic_organization_id = var.sumologic_organization_id

  wait_for_seconds = 20
  aws_resource_tags = local.aws_resource_tags
  iam_details = {
    create_iam_role = true
    iam_role_arn    = null
  }

  create_inventory_source = true
  inventory_source_details = {
    source_name         = "AWS Inventory ${local.aws_region}"
    source_category     = "aws/observability/inventory"
    collector_id        = module.root_cause_sources_module.sumologic_collector.collector.id
    description         = "This source is created using Sumo Logic terraform AWS Observability module to collect AWS inventory metadata."
    limit_to_namespaces = [
      "AWS/ApplicationELB", "AWS/ApiGateway", "AWS/DynamoDB", "AWS/Lambda", "AWS/RDS", "AWS/ECS", "AWS/ElastiCache",
      "AWS/ELB", "AWS/NetworkELB", "AWS/SQS", "AWS/SNS", "AWS/AutoScaling", "AWS/EC2"
    ]
    limit_to_regions    = [local.aws_region]
    paused              = false
    scan_interval       = 300000
    sumo_account_id     = 926226587429
    fields              = {}
  }

  create_xray_source = true
  xray_source_details = {
    source_name      = "AWS Xray ${local.aws_region}"
    source_category  = "aws/observability/xray"
    collector_id     = module.root_cause_sources_module.sumologic_collector.collector.id
    description      = "This source is created using Sumo Logic terraform AWS Observability module to collect AWS Xray metrics."
    limit_to_regions = [local.aws_region]
    paused           = false
    scan_interval    = 300000
    sumo_account_id  = 926226587429
    fields           = {}
  }
}