terraform {
  required_version = ">= 0.13.0"

  required_providers {
    sumologic = {
      version = ">= 2.31.3, < 4.0.0"
      source  = "SumoLogic/sumologic"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.16.2, < 6.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.1.0"
    }
  }
}
