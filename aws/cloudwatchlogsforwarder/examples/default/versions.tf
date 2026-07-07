terraform {
  required_version = ">= 1.5.7"

  required_providers {
    sumologic = {
      version = ">= 3.2.9, < 4.0.0"
      source  = "SumoLogic/sumologic"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.16.2, < 7.0.0"
    }
  }
}
