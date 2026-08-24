resource "random_string" "aws_random" {
  length  = 10
  upper   = false
  special = false
}

module "s3_logging_auto_enable_module" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/autoenable/modules/s3_loggings"
  version = "3.0.0"

  providers = {
    aws       = aws
    sumologic = sumologic
  }

  auto_enable_logging           = "ALB"
  auto_enable_resource_options  = "Both"
  bucket_name                  = "aws-observability-sam-akhil90"
  bucket_prefix                = "exmaple/aws-alb/both"
  filter_expression            = "'Type': 'application'|'type': 'application'"
  remove_on_delete_stack       = true

  aws_resource_tags = {
    Environment = "prod"
    Project     = "logging"
  }
}