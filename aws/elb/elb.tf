# *************** Steps are as Below to create Sumo Logic ELB source *************** #
# 1. Create AWS S3 Bucket. If the Bucket is created, create SNS Topic and SNS policy to attach to Bucket.
# 2. Create IAM role in AWS with access to the bucket name provided.
# 3. Create a Collector. If the Collector ID is provided, do not create a Collector.
# 4. Create the source either in the collector created or in the collector id provided.
# 5. Create SNS Subscription to be attached to the source and SNS Topic.
# 6. Add SAM app for auto enable of access logs for ELBs.

resource "random_string" "aws_random" {
  length  = 10
  special = false
  upper   = false
}

resource "aws_s3_bucket" "s3_bucket" {
  for_each = toset(var.source_details.bucket_details.create_bucket ? ["s3_bucket"] : [])

  bucket        = local.bucket_name
  force_destroy = var.source_details.bucket_details.force_destroy_bucket
  tags          = var.aws_resource_tags
}

resource "aws_s3_bucket_policy" "dump_access_logs_to_s3" {
  for_each = toset(var.source_details.bucket_details.create_bucket ? ["s3_bucket"] : [])

  bucket = aws_s3_bucket.s3_bucket["s3_bucket"].id
  policy = templatefile("${path.module}/templates/elb_bucket_policy.tmpl", {
    BUCKET_NAME     = local.bucket_name
    ELB_ACCCOUNT_ID = local.region_to_elb_account_id[local.aws_region]
    AWS_PARTITION   = data.aws_partition.current.partition
  })
}

resource "aws_sns_topic" "sns_topic" {
  for_each = toset(var.source_details.sns_topic_details.create_sns_topic ? ["sns_topic"] : [])

  name = "SumoLogic-Terraform-Elb-Module-${random_string.aws_random.id}"
  policy = templatefile("${path.module}/templates/sns_topic_policy.tmpl", {
    BUCKET_NAME    = local.bucket_name,
    AWS_REGION     = local.aws_region,
    SNS_TOPIC_NAME = "SumoLogic-Terraform-Elb-Module-${random_string.aws_random.id}",
    AWS_ACCOUNT    = local.aws_account_id
    AWS_PARTITION  = data.aws_partition.current.partition
  })
  tags = var.aws_resource_tags
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  for_each = toset(var.source_details.sns_topic_details.create_sns_topic && var.source_details.bucket_details.create_bucket ? ["bucket_notification"] : [])

  bucket = aws_s3_bucket.s3_bucket["s3_bucket"].id

  topic {
    topic_arn = aws_sns_topic.sns_topic["sns_topic"].arn
    events    = ["s3:ObjectCreated:Put"]
  }
}

resource "aws_iam_role" "source_iam_role" {
  for_each = toset(var.source_details.iam_details.create_iam_role ? ["source_iam_role"] : [])

  name = "SumoLogic-Terraform-Elb-Module-${random_string.aws_random.id}"
  path = "/"

  assume_role_policy = templatefile("${path.module}/templates/sumologic_assume_role.tmpl", {
    SUMO_LOGIC_ACCOUNT_ID = local.sumo_account_ids[data.aws_partition.current.partition]
    ENVIRONMENT           = data.sumologic_caller_identity.current.environment
    SUMO_LOGIC_ORG_ID     = var.sumologic_organization_id
    AWS_PARTITION         = data.aws_partition.current.partition
  })
  tags = var.aws_resource_tags
}

resource "aws_iam_policy" "iam_policy" {
  for_each = toset(var.source_details.iam_details.create_iam_role ? ["iam_policy"] : [])

  name = "SumoLogicElbSource-${random_string.aws_random.id}"
  policy = templatefile("${path.module}/templates/sumologic_source_policy.tmpl", {
    BUCKET_NAME           = local.bucket_name
    AWS_PARTITION         = data.aws_partition.current.partition
  })
  tags = var.aws_resource_tags
}

resource "aws_iam_role_policy_attachment" "source-role-policy-attach" {
  for_each   = toset(var.source_details.iam_details.create_iam_role ? ["source_iam_role"] : [])
  role       = aws_iam_role.source_iam_role["source_iam_role"].name
  policy_arn = aws_iam_policy.iam_policy["iam_policy"].arn
}

resource "sumologic_collector" "collector" {
  for_each    = toset(var.create_collector ? ["collector"] : [])
  name        = local.collector_name
  description = var.collector_details.description
  fields      = var.collector_details.fields
  timezone    = "UTC"
}

resource "time_sleep" "wait_for_seconds" {
  create_duration = "${var.wait_for_seconds}s"
}

resource "sumologic_elb_source" "source" {
  depends_on = [
    time_sleep.wait_for_seconds
  ]

  lifecycle {
    ignore_changes = [cutoff_timestamp, cutoff_relative_time]
  }
  category             = var.source_details.source_category
  collector_id         = var.create_collector ? sumologic_collector.collector["collector"].id : var.source_details.collector_id
  content_type         = "AwsElbBucket"
  cutoff_relative_time = var.source_details.cutoff_relative_time
  description          = var.source_details.description
  fields               = var.source_details.fields
  name                 = var.source_details.source_name
  paused               = var.source_details.paused
  scan_interval        = var.source_details.scan_interval
  authentication {
    type     = "AWSRoleBasedAuthentication"
    role_arn = var.source_details.iam_details.create_iam_role ? aws_iam_role.source_iam_role["source_iam_role"].arn : var.source_details.iam_details.iam_role_arn
  }

  path {
    type            = "S3BucketPathExpression"
    bucket_name     = var.source_details.bucket_details.create_bucket ? aws_s3_bucket.s3_bucket["s3_bucket"].id : local.bucket_name
    path_expression = local.logs_path_expression
  }
}

resource "aws_sns_topic_subscription" "subscription" {
  delivery_policy = jsonencode({
    "guaranteed" = false,
    "healthyRetryPolicy" = {
      "numRetries"         = 40,
      "minDelayTarget"     = 10,
      "maxDelayTarget"     = 300,
      "numMinDelayRetries" = 3,
      "numMaxDelayRetries" = 5,
      "numNoDelayRetries"  = 0,
      "backoffFunction"    = "exponential"
    },
    "sicklyRetryPolicy" = null,
    "throttlePolicy"    = null
  })
  endpoint               = sumologic_elb_source.source.url
  endpoint_auto_confirms = true
  protocol               = "https"
  topic_arn              = var.source_details.sns_topic_details.create_sns_topic ? aws_sns_topic.sns_topic["sns_topic"].arn : var.source_details.sns_topic_details.sns_topic_arn
}

# Reason to use the SAM app, is to have single source of truth for Auto Enable access logs functionality.
# Ignore changes has been implemented to bypass aws resource issue: https://github.com/hashicorp/terraform-provider-aws/issues/16485
# resource "aws_serverlessapplicationrepository_cloudformation_stack" "auto_enable_access_logs" {
#   for_each = toset(local.auto_enable_access_logs ? ["auto_enable_access_logs"] : [])
#
#   name             = "Auto-Enable-Access-Logs-Elb-${random_string.aws_random.id}"
#   application_id   = "arn:aws:serverlessrepo:us-east-1:956882708938:applications/sumologic-s3-logging-auto-enable"
#   semantic_version = var.app_semantic_version
#   capabilities     = data.aws_serverlessapplicationrepository_application.app.required_capabilities
#   parameters = {
#     BucketName                = local.bucket_name
#     BucketPrefix              = "elasticloadbalancing"
#     AutoEnableLogging         = "ALB"
#     AutoEnableResourceOptions = var.auto_enable_access_logs
#     FilterExpression          = var.auto_enable_access_logs_options.filter
#     RemoveOnDeleteStack       = var.auto_enable_access_logs_options.remove_on_delete_stack
#   }
#   lifecycle {
#     ignore_changes = [
#       parameters, tags
#     ]
#   }
#   tags = var.aws_resource_tags
# }

module "auto_enable_access_logs_module" {
  #source = "/Users/akhil.dangore.ctr/Documents/ProjectSource/terraform-sumologic-sumo-logic-integrations/aws/autoenable/modules/s3_logging"
  source = "git::https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations.git//aws/autoenable/modules/s3_logging?ref=fy27q2"

  providers = {
    aws                         = aws
    lambda-invoke-extension     = lambda-invoke-extension
  }

  auto_enable_logging           = "ALB"
  auto_enable_resource_options  = var.auto_enable_access_logs
  bucket_name                   = local.bucket_name
  bucket_prefix                 = "elasticloadbalancing"
  filter_expression             = var.auto_enable_access_logs_options.filter
  remove_on_delete_stack        = var.auto_enable_access_logs_options.remove_on_delete_stack

  aws_resource_tags             = var.aws_resource_tags
}