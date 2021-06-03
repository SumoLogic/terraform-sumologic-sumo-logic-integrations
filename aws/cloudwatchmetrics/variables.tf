variable "create_collector" {
  type        = bool
  description = "Provide \"true\" if you would like to create the Sumo Logic Collector."
}

variable "collector_details" {
  type = object({
    collector_name = string
    description    = string
    fields         = map(string)
  })
  description = "Provide details for the Sumo Logic collector. If not provided, then defaults will be used."
  default = {
    collector_name = "SumoLogic CloudWatch Metrics Collector <AWS Account Id>"
    description    = "This collector is created using Sumo Logic terraform AWS Cloudwatch metrics module to collect AWS cloudwatch metrics."
    fields         = {}
  }
}

variable "source_details" {
  type = object({
    source_name         = string
    source_category     = string
    collector_id        = string
    description         = string
    limit_to_regions    = list(string)
    limit_to_namespaces = list(string)
    paused              = bool
    scan_interval       = number
    sumo_account_id     = number
    fields              = map(string)
    iam_role_arn        = string
  })
  description = "Provide details for the Sumo Logic Cloudwatch Metrics source. If not provided, then defaults will be used."
  default = {
    source_name         = "CloudWatch Metrics Source"
    source_category     = "Labs/aws/cloudwatch/metrics"
    description         = "This source is created using Sumo Logic terraform AWS CloudWatch Metrics module to collect AWS Cloudwatch metrics."
    collector_id        = ""
    limit_to_regions    = []
    limit_to_namespaces = []
    scan_interval       = 300000
    paused              = false
    sumo_account_id     = 926226587429
    fields              = {}
    iam_role_arn        = ""
  }
}

variable "sumologic_organization_id" {
  type        = string
  description = "Appears on the Account Overview page that displays information about your Sumo Logic organization. Used for IAM Role in Sumo Logic AWS Sources."

  validation {
    condition     = can(regex("\\w+", var.sumologic_organization_id))
    error_message = "The organization ID must contain valid characters."
  }
}