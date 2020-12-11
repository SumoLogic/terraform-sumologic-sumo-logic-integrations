# Some common data
locals {
  time_stamp = formatdate("DD-MMM-YYYY hh:mm:ss", timestamp())
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "SumoLogicTopicPolicy"

  statement {
    actions = [
      "sns:Publish",
    ]

    condition {
      test = "StringEquals"
      variable = "AWS:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    condition {
      test = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:s3:::${aws_s3_bucket.aws_s3_bucket.id}",
      ]
    }

    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "s3.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.aws_s3_bucket_sns_topic.arn,
    ]
  }
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.aws_s3_bucket.id}",
    ]
  }

  statement {
    sid = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.aws_s3_bucket.id}/*",
    ]

    condition {
      test = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }

  statement {
    sid = "AWSBucketExistenceCheck"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.aws_s3_bucket.id}",
    ]
  }
}

data "aws_iam_policy_document" "sumologic_source_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.sumo_aws_account_id}:root",
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        var.sumo_external_id,
      ]
    }
  }
}

data "aws_iam_policy_document" "sumologic_logs_s3_read" {
  statement {
    sid = "SumologicAccess"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucketVersions",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.aws_s3_bucket.id}",
      "arn:aws:s3:::${aws_s3_bucket.aws_s3_bucket.id}/*",
    ]
  }
}

# Create CloudTrail in AWS account. Also, create SNS Topic to attach to the bucket.
resource "aws_sns_topic" "aws_s3_bucket_sns_topic" {
  name = var.aws_resource_name
}

resource "aws_sns_topic_policy" "aws_s3_bucket_sns_policy" {
  arn = aws_sns_topic.aws_s3_bucket_sns_topic.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

resource "aws_s3_bucket" "aws_s3_bucket" {
  depends_on = [aws_sns_topic.aws_s3_bucket_sns_topic]
  bucket = var.aws_resource_name
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  depends_on = [aws_sns_topic_subscription.sns_topic]
  bucket = aws_s3_bucket.aws_s3_bucket.id

  topic {
    topic_arn = aws_sns_topic.aws_s3_bucket_sns_topic.arn
    events = [
      "s3:ObjectCreated:Put"]
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy" {
  bucket = aws_s3_bucket.aws_s3_bucket.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

resource "aws_sns_topic_subscription" "sns_topic" {
  topic_arn = aws_sns_topic.aws_s3_bucket_sns_topic.arn
  protocol  = "https"
  endpoint  = sumologic_cloudtrail_source.terraform_cloudtrail_source.url
  endpoint_auto_confirms = true
}

resource "aws_cloudtrail" "aws_s3_cloudtrail" {
  depends_on = [aws_s3_bucket_policy.aws_s3_bucket_policy]
  name = var.aws_resource_name
  s3_bucket_name = aws_s3_bucket.aws_s3_bucket.id
  enable_logging = true
  is_multi_region_trail = false
}

# This will be created when source is created. Get a flag to create source.
resource aws_iam_role "sumologic" {
  name               = var.aws_resource_name
  assume_role_policy = data.aws_iam_policy_document.sumologic_source_role_policy.json
  description        = "Allows Sumologic Access"
}

resource "aws_iam_policy" "sumologic_logs_policy" {
  name        = var.aws_resource_name
  policy      = data.aws_iam_policy_document.sumologic_logs_s3_read.json
  description = "Allow Sumologic to read S3 Cloudwatch Logs and S3 Access Logs"
}

resource aws_iam_role_policy_attachment sumologic_logs_policy_attach {
  role       = aws_iam_role.sumologic.id
  policy_arn = aws_iam_policy.sumologic_logs_policy.arn
}

# Create if the provided collector name does not exist
resource "sumologic_collector" "collector" {
  name        = var.sumo_collector_name
  description = "Sumo Logic Collector for CloudTrail"
}

# Create the source based on a flag.
resource "sumologic_cloudtrail_source" "terraform_cloudtrail_source" {
  depends_on = [aws_cloudtrail.aws_s3_cloudtrail]
  name          = var.sumo_source_name
  description   = "Sumo Logic Source for CloudTrail"
  category      = var.sumo_source_category
  content_type  = "AwsCloudTrailBucket"
  scan_interval = 300000
  paused        = false
  collector_id  = sumologic_collector.collector.id

  authentication {
    type = "AWSRoleBasedAuthentication"
    role_arn = aws_iam_role.sumologic.arn
  }

  path {
    type = "S3BucketPathExpression"
    bucket_name     = aws_s3_bucket.aws_s3_bucket.id
    path_expression = "*"
  }
}

# Install all available Sumo Logic cloudtrail apps
resource "null_resource" "install_cloudtrail_app" {
  triggers = {
        version = var.app_version
  }

  provisioner "local-exec" {
    command = <<EOT
        curl -s --request POST '${var.sumo_api_endpoint}apps/ceb7fac5-1137-4a04-a5b8-2e49190be3d4/install' \
            --header 'Accept: application/json' \
            --header 'Content-Type: application/json' \
            -u "${var.sumo_access_id}:${var.sumo_access_key}" \
            --data-raw '{ "name": "AWS CloudTrail - ${local.time_stamp}", "description": "The Sumo Logic App for AWS CloudTrail helps you monitor your AWS deployments using CloudTrail Logs", "destinationFolderId": "${var.folder_id}","dataSourceValues": {"logsrc": "_sourceCategory = ${var.sumo_source_category}" }}'
    EOT
  }
}

resource "null_resource" "install_pci_cloudtrail_app" {
  triggers = {
        version = var.app_version
  }

  provisioner "local-exec" {
    command = <<EOT
        curl -s --request POST '${var.sumo_api_endpoint}apps/924d7e2a-a14a-4b11-8c91-133241be2a51/install' \
            --header 'Accept: application/json' \
            --header 'Content-Type: application/json' \
            -u "${var.sumo_access_id}:${var.sumo_access_key}" \
            --data-raw '{ "name": "PCI Compliance For AWS CloudTrail - ${local.time_stamp}", "description": "The Sumo Logic App for PCI Compliance For AWS CloudTrail helps you monitor your AWS deployments using CloudTrail Logs", "destinationFolderId": "${var.folder_id}","dataSourceValues": {"CloudtrailLogSrc": "_sourceCategory = ${var.sumo_source_category}" }}'
    EOT
  }
}

resource "null_resource" "install_cis_foundation_app" {
  triggers = {
        version = var.app_version
  }

  provisioner "local-exec" {
    command = <<EOT
        curl -s --request POST '${var.sumo_api_endpoint}apps/9f630fe6-9253-4700-bb7e-36afc97b8cb6/install' \
            --header 'Accept: application/json' \
            --header 'Content-Type: application/json' \
            -u "${var.sumo_access_id}:${var.sumo_access_key}" \
            --data-raw '{ "name": "CIS AWS Foundations Benchmark - ${local.time_stamp}", "description": "The Sumo Logic App for CIS AWS Foundations Benchmark helps you monitor your AWS deployments using CloudTrail Logs", "destinationFolderId": "${var.folder_id}","dataSourceValues": {"paramId123": "_sourceCategory = ${var.sumo_source_category}" }}'
    EOT
  }
}