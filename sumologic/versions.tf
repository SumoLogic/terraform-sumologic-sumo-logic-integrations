terraform {
  required_version = ">= 1.5.7"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 2.1"
    }
    sumologic = {
      version = ">= 3.2.9, < 4.0.0"
      source  = "SumoLogic/sumologic"
    }
  }
}