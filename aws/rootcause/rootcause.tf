# *************** Steps are as Below to create Sumo Logic Root Cause sources *************** #
# 1. Create IAM role in AWS with access to the XRAY and Inventory APIs.
# 2. Create a Collector. If the Collector ID is provided, do not create a Collector.
# 3. Create the source either in the collector created or in the collector id provided.

resource "random_string" "aws_random" {
  length  = 10
  special = false
}

resource "aws_iam_role" "source_iam_role" {
  for_each = toset(local.create_iam_role ? ["source_iam_role"] : [])

  name = "SumoLogic-RootCause-Module-${random_string.aws_random.id}"
  path = "/"

  assume_role_policy = templatefile("${path.module}/templates/sumologic_assume_role.tmpl", {
    SUMO_LOGIC_ACCOUNT_ID = var.inventory_source_details.sumo_account_id,
    ENVIRONMENT           = data.sumologic_caller_identity.current.environment,
    SUMO_LOGIC_ORG_ID     = var.sumologic_organization_id
  })

  managed_policy_arns = [aws_iam_policy.iam_policy["iam_policy"].arn]
}

resource "aws_iam_policy" "iam_policy" {
  for_each = toset(local.create_iam_role ? ["iam_policy"] : [])

  name   = "SumoLogicCloudWatchMetricsSource-${random_string.aws_random.id}"
  policy = templatefile("${path.module}/templates/sumologic_source_policy.tmpl", {})
}

resource "sumologic_collector" "collector" {
  for_each    = toset(var.create_collector ? ["collector"] : [])
  name        = local.collector_name
  description = var.collector_details.description
  fields      = var.collector_details.fields
  timezone    = "UTC"
}

resource "time_sleep" "wait_3_minutes" {
  create_duration = "180s"
}

resource "sumologic_aws_inventory_source" "aws_inventory_source" {
  for_each = toset(var.create_inventory_source ? ["aws_inventory_source"] : [])
  depends_on = [
    time_sleep.wait_3_minutes
  ]
  name          = var.inventory_source_details.source_name
  description   = var.inventory_source_details.description
  category      = var.inventory_source_details.source_category
  content_type  = "AwsInventory"
  scan_interval = var.inventory_source_details.scan_interval
  paused        = var.inventory_source_details.paused
  collector_id  = var.create_collector ? sumologic_collector.collector["collector"].id : var.inventory_source_details.collector_id
  fields        = var.inventory_source_details.fields

  authentication {
    type     = "AWSRoleBasedAuthentication"
    role_arn = local.create_iam_role ? aws_iam_role.source_iam_role["source_iam_role"].arn : var.inventory_source_details.iam_role_arn
  }

  path {
    type                = "AwsInventoryPath"
    limit_to_regions    = var.inventory_source_details.limit_to_regions
    limit_to_namespaces = var.inventory_source_details.limit_to_namespaces
  }
}

resource "sumologic_aws_xray_source" "aws_xray_source" {
  for_each = toset(var.create_inventory_source ? ["aws_xray_source"] : [])
  depends_on = [
    time_sleep.wait_3_minutes
  ]
  name          = var.xray_source_details.source_name
  description   = var.xray_source_details.description
  category      = var.xray_source_details.source_category
  content_type  = "AwsXRay"
  scan_interval = var.xray_source_details.scan_interval
  paused        = var.xray_source_details.paused
  collector_id  = var.create_collector ? sumologic_collector.collector["collector"].id : var.xray_source_details.collector_id
  fields        = var.xray_source_details.fields

  authentication {
    type     = "AWSRoleBasedAuthentication"
    role_arn = local.create_iam_role ? aws_iam_role.source_iam_role["source_iam_role"].arn : var.xray_source_details.iam_role_arn
  }

  path {
    type             = "AwsXRayPath"
    limit_to_regions = var.xray_source_details.limit_to_regions
  }
}

