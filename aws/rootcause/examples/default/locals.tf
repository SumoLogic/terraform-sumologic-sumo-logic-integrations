locals {
  # AWS account details
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  # AWS resource tags
  aws_resource_tags = {
    Creator        = "SumoLogic"
    Environment = "Test"
  }
}