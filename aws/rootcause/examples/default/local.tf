
locals {

    # AWS account details
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  # Sumo AWS account ID
  sumo_account_id = "926226587429"

  # Sumo account Details
  sumologic_organization_id = "0000000000285A74"
  sumologic_existing_collector_id = 254493957
  sumologic_environment = "us1"

  inventory_source_details = {
    source_name         = "AWS Inventory ${local.aws_region}"
    source_category     = "aws/observability/inventory"
    description         = "This source is created using Sumo Logic terraform AWS Observability module to collect AWS inventory metadata."
    limit_to_namespaces = [
      "AWS/ApplicationELB", "AWS/ApiGateway", "AWS/DynamoDB", "AWS/Lambda", "AWS/RDS", "AWS/ECS", "AWS/ElastiCache",
      "AWS/ELB", "AWS/NetworkELB", "AWS/SQS", "AWS/SNS", "AWS/AutoScaling", "AWS/EC2"
    ]
    fields              = {}
  }

  xray_source_details = {
    source_name     = "AWS Xray ${local.aws_region}"
    source_category = "aws/observability/xray"
    description     = "This source is created using Sumo Logic terraform AWS Observability module to collect AWS Xray metrics."
    fields          = {}
  }

  # Root Cause sources updated details
  create_inventory_source  = true
  create_xray_source       = true
  create_root_cause_source = true
  }