terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.16.2, < 7.0.0"
    }
    sumologic = {
      version = ">= 3.3.0, < 4.0.0"
      source  = "SumoLogic/sumologic"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.11.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}