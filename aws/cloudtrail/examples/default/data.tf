data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "sumologic_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_region_data" {
  value = data.aws_region.current
}

output "sumologic_env" {
  value = data.sumologic_caller_identity.current
}