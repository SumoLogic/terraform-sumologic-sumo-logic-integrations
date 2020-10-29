terraform {
  required_version = ">= 0.12.26"

  required_providers {
    sumologic = {
      version = "~> 2.1.0"
      source = "SumoLogic/sumologic"
    }
    template = {
      version = "~> 2.1"
    }
  }
}