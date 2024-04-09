

module "root_cause_sources_module" {
  for_each   = toset(local.create_root_cause_source ? ["root_cause_sources_module"] : [])
  source = "../../../rootcause"

  create_collector          = false
  sumologic_organization_id = local.sumologic_organization_id

  wait_for_seconds = 20
  iam_details = {
    create_iam_role = true
    iam_role_arn    = null
  }

  create_inventory_source = local.create_inventory_source
  inventory_source_details = {
    source_name         = local.inventory_source_details.source_name
    source_category     = local.inventory_source_details.source_category
    collector_id        = local.sumologic_existing_collector_id
    description         = local.inventory_source_details.description
    limit_to_namespaces = local.inventory_source_details.limit_to_namespaces
    limit_to_regions    = [local.aws_region]
    paused              = false
    scan_interval       = 300000
    sumo_account_id     = local.sumo_account_id
    fields              = local.inventory_source_details.fields
  }

  create_xray_source = local.create_xray_source
  xray_source_details = {
    source_name      = local.xray_source_details.source_name
    source_category  = local.xray_source_details.source_category
    collector_id     = local.sumologic_existing_collector_id
    description      = local.xray_source_details.description
    limit_to_regions = [local.aws_region]
    paused           = false
    scan_interval    = 300000
    sumo_account_id  = local.sumo_account_id
    fields           = local.xray_source_details.fields
  }
}