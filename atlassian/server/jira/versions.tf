terraform {
  required_version = ">= 1.5.7"

  required_providers {
    null = {
      version = "~> 2.1"
    }
    jira = {
      source = "fourplusone/jira"
      version = "~> 0.1.14"
    }
    sumologic = {
      version = "~> 2.1.0"
      source = "SumoLogic/sumologic"
    }
  }
}