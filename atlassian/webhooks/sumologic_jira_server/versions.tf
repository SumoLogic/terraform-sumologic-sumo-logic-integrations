terraform {
  required_version = ">= 1.5.7"

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