terraform {
  required_version = ">= 1.5.7"

  required_providers {
    null = {
      version = "~> 2.1"
    }
    bitbucket = {
      source = "terraform-providers/bitbucket"
      version = "~> 1.2"
    }
    sumologic = {
      version = "~> 2.1.0"
      source = "SumoLogic/sumologic"
    }
  }
}