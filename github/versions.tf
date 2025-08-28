terraform {
  required_version = ">= 1.5.7"

  required_providers {
    null = {
      version = "~> 2.1"
    }
    github = {
      source = "hashicorp/github"
      version = "~> 2.8"
    }
    sumologic = {
      version = "~> 2.1.0"
      source = "SumoLogic/sumologic"
    }
  }
}