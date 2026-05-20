locals {

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

  # Random ID simulation for naming
  random_id_part = substr(random_string.stack_suffix.id, 0, 8)

  create_invoke_permission = var.destination_arn_type == "Lambda"
  create_pass_role         = var.destination_arn_type == "Kinesis"
  invoke_existing          = var.use_existing_logs == "true"
}
