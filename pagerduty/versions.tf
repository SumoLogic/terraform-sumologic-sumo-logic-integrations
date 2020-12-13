terraform {
  required_version = ">= 0.13.0"

  required_providers {
    null = {
      version = "~> 2.1"
    }
    pagerduty = {
      source = "pagerduty/pagerduty"
      version = "~> 1.7"
    }
    sumologic = {
      version = "~> 2.1.0"
      source = "SumoLogic/sumologic"
    }
  }
}