terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0.0"
    }
    sumologic = {
      version = "~> 2.6.0"
      source  = "SumoLogic/sumologic"
    }
  }
}