resource "random_string" "aws_random" {
  length  = 10
  upper   = false
  special = false
}

module "auto_enable_module" {
  source = "/Users/akhil.dangore.ctr/Documents/ProjectSource/terraform-sumologic-sumo-logic-integrations/aws/autoenable"

  providers = {
    aws                    = aws
    lambda-invoke-extension = lambda-invoke-extension
  }

  auto_enable_logging           = "ALB"
  auto_enable_resource_options  = "New"
  bucket_name                  = "aws-observability-sam-akhil90"
  bucket_prefix                = "exmaple/aws-alb/both"
  filter_expression            = "'Type': 'application'|'type': 'application'"
  remove_on_delete_stack       = true

  aws_resource_tags = {
    Environment = "prod"
    Project     = "logging"
  }
}