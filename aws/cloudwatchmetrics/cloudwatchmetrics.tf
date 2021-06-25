# *************** Steps are as Below to create Sumo Logic CloudWatch Metrics source *************** #
# 1. Create IAM role in AWS with access to the cloudwatch metrics.
# 2. Create a Collector. If the Collector ID is provided, do not create a Collector.
# 3. Create the source either in the collector created or in the collector id provided.

resource "random_string" "aws_random" {
  length  = 10
  special = false
}

resource "aws_iam_role" "source_iam_role" {
  for_each = toset(var.source_details.iam_details.create_iam_role ? ["source_iam_role"] : [])

  name = "SumoLogic-CloudWatch-Metrics-Module-${random_string.aws_random.id}"
  path = "/"

  assume_role_policy = templatefile("${path.module}/templates/sumologic_assume_role.tmpl", {
    SUMO_LOGIC_ACCOUNT_ID = var.source_details.sumo_account_id,
    ENVIRONMENT           = data.sumologic_caller_identity.current.environment,
    SUMO_LOGIC_ORG_ID     = var.sumologic_organization_id
  })

  managed_policy_arns = [aws_iam_policy.iam_policy["iam_policy"].arn]
}

resource "aws_iam_policy" "iam_policy" {
  for_each = toset(var.source_details.iam_details.create_iam_role ? ["iam_policy"] : [])

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

resource "time_sleep" "wait_for_minutes" {
  create_duration = "${var.wait_for_seconds}s"
}

resource "sumologic_cloudwatch_source" "cloudwatch_metrics_sources" {
  depends_on = [
    time_sleep.wait_for_minutes
  ]
  category      = var.source_details.source_category
  collector_id  = var.create_collector ? sumologic_collector.collector["collector"].id : var.source_details.collector_id
  content_type  = "AwsCloudWatch"
  description   = var.source_details.description
  fields        = var.source_details.fields
  name          = var.source_details.source_name
  paused        = false
  scan_interval = var.source_details.scan_interval

  authentication {
    type     = "AWSRoleBasedAuthentication"
    role_arn = var.source_details.iam_details.create_iam_role ? aws_iam_role.source_iam_role["source_iam_role"].arn : var.source_details.iam_details.iam_role_arn
  }

  path {
    type                = "CloudWatchPath"
    limit_to_regions    = var.source_details.limit_to_regions
    limit_to_namespaces = var.source_details.limit_to_namespaces
  }
}

