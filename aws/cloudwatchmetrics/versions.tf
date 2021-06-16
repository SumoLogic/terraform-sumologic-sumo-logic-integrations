terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.29.1"
    }
    sumologic = {
      version = "~> 2.6.0"
      source  = "SumoLogic/sumologic"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.7.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}