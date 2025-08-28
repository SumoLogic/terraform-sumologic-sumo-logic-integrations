terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
    sumologic = {
      source  = "SumoLogic/sumologic"
      version = ">= 2.11"
    }
  }
  required_version = ">= 1.5.7"
}
