terraform {
  required_version = ">= 0.13.0"

  required_providers {
    sumologic = {
      version = ">= 2.10.0"
      source  = "SumoLogic/sumologic"
    }
   }
}