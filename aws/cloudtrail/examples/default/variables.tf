variable "sumologic_access_id" {
  type        = string
  description = "Please provide access ID for your Sumo Account"
}

variable "sumologic_access_key" {
  type        = string
  description = "Please provide access key for your Sumo Account"
}

variable "sumologic_environment" {
  type        = string
  description = "Please provide SumoLogic deployment environment"
}

variable "sumologic_organization_id" {
  type        = string
  description = "Appears on the Account Overview page that displays information about your Sumo Logic organization. Used for IAM Role in Sumo Logic AWS Sources."

  validation {
    condition     = can(regex("\\w+", var.sumologic_organization_id))
    error_message = "The organization ID must contain valid characters."
  }
}