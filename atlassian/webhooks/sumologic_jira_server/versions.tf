terraform {
  required_version = ">= 0.13.0"

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