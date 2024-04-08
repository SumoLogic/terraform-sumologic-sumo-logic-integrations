provider "sumologic" {
  environment = var.sumologic_environment
  access_id   = var.sumologic_access_id
  access_key  = var.sumologic_access_key
}

provider "aws" {
  region = "us-east-1"
  #
  # Below properties should be added when you would like to onboard more than one region and account
  # More Information regarding AWS Profile can be found at -
  #
  # Access configuration
  #
  # profile = <Provide a profile as setup in AWS CLI>
  #
  # Terraform alias
  #
  # alias = <Provide a terraform alias for the aws provider. For eg :- production-us-east-1>
}