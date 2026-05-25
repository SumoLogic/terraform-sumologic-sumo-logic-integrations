terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.16.2, < 7.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.1.0"
    }
    lambda-invoke-extension = {
      source = "registry.terraform.io/local-dev/lambda-invoke-extension"
      #version = "0.1.0"
    }
  }
}