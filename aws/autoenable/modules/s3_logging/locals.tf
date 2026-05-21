locals {

  aws_region = data.aws_region.current.id

  region_bucket_map = {
    "us-east-1"      = "appdevzipfiles-us-east-1"
    "us-east-2"      = "appdevzipfiles-us-east-2"
    "us-west-1"      = "appdevzipfiles-us-west-1"
    "us-west-2"      = "appdevzipfiles-us-west-2"
    "ap-south-1"     = "appdevzipfiles-ap-south-1"
    "ap-northeast-2" = "appdevzipfiles-ap-northeast-2"
    "ap-southeast-1" = "appdevzipfiles-ap-southeast-1"
    "ap-southeast-2" = "appdevzipfiles-ap-southeast-2"
    "ap-northeast-1" = "appdevzipfiles-ap-northeast-1"
    "ca-central-1"   = "appdevzipfiles-ca-central-1"
    "eu-central-1"   = "appdevzipfiles-eu-central-1"
    "eu-west-1"      = "appdevzipfiles-eu-west-1"
    "eu-west-2"      = "appdevzipfiles-eu-west-2"
    "eu-west-3"      = "appdevzipfiles-eu-west-3"
    "eu-north-1"     = "appdevzipfiles-eu-north-1s"
    "sa-east-1"      = "appdevzipfiles-sa-east-1"
    "ap-east-1"      = "appdevzipfiles-ap-east-1s"
    "af-south-1"     = "appdevzipfiles-af-south-1s"
    "eu-south-1"     = "appdevzipfiles-eu-south-1"
    "me-south-1"     = "appdevzipfiles-me-south-1s"
    "me-central-1"   = "appdevzipfiles-me-central-1"
    "eu-central-2"   = "appdevzipfiles-eu-central-2ss"
    "ap-northeast-3" = "appdevzipfiles-ap-northeast-3s"
    "ap-southeast-3" = "appdevzipfiles-ap-southeast-3"
    "il-central-1"   = "appdevzipfiles-il-central-1"
  }

  # s3_logging_auto_enable
  # Conditions
  enable_alb_logging          = var.auto_enable_logging == "ALB"
  enable_elb_logging          = var.auto_enable_logging == "ELB"
  enable_s3_buckets_logging   = var.auto_enable_logging == "S3"
  enable_vpc_flow_logs        = var.auto_enable_logging == "VPC"

  auto_enable_existing = contains(["Existing", "Both"], var.auto_enable_resource_options)
  auto_enable_new      = contains(["New", "Both"], var.auto_enable_resource_options)

  enable_alb_log_events = local.auto_enable_new && local.enable_alb_logging
  enable_elb_log_events = local.auto_enable_new && local.enable_elb_logging
  enable_s3_log_events  = local.auto_enable_new && local.enable_s3_buckets_logging
  enable_vpc_log_events = local.auto_enable_new && local.enable_vpc_flow_logs

  # Random ID simulation for naming
  random_id_part = substr(random_string.stack_suffix.id, 0, 8)

  aws_resource = local.enable_s3_buckets_logging ? "s3" : (
    local.enable_vpc_flow_logs ? "vpc" : (
      local.enable_alb_logging ? "elbv2" : "elb"
    )
  )
}
