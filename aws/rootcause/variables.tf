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
    collector_name = "SumoLogic RootCause Collector <Random ID>"
    description    = "This collector is created using Sumo Logic terraform AWS Root Cause module."
    fields         = {}
  }
}

variable "create_inventory_source" {
  type        = bool
  description = "Provide \"true\" if you would like to create the Sumo Logic AWS Inventory source."
}

variable "inventory_source_details" {
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
  })
  description = "Provide details for the Sumo Logic AWS Inventory source. If not provided, then defaults will be used."
  default = {
    source_name         = "Inventory Source"
    source_category     = "Labs/inventory"
    description         = "This source is created using Sumo Logic terraform AWS RootCause module to collect AWS inventory metadata."
    collector_id        = ""
    limit_to_regions    = []
    limit_to_namespaces = []
    scan_interval       = 300000
    paused              = false
    sumo_account_id     = 926226587429
    fields              = {}
  }
}

variable "create_xray_source" {
  type        = bool
  description = "Provide \"true\" if you would like to create the Sumo Logic AWS Xray source."
}

variable "xray_source_details" {
  type = object({
    source_name      = string
    source_category  = string
    collector_id     = string
    description      = string
    limit_to_regions = list(string)
    paused           = bool
    scan_interval    = number
    sumo_account_id  = number
    fields           = map(string)
  })
  description = "Provide details for the Sumo Logic AWS XRAY source. If not provided, then defaults will be used."
  default = {
    source_name      = "Xray Source"
    source_category  = "Labs/xray"
    description      = "This source is created using Sumo Logic terraform AWS RootCause module to collect AWS Xray metrics."
    collector_id     = ""
    limit_to_regions = []
    scan_interval    = 300000
    paused           = false
    sumo_account_id  = 926226587429
    fields           = {}
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

variable "iam_details" {
  type = object({
    create_iam_role = bool
    iam_role_arn    = string
  })
  description = "Provide an existing AWS IAM role ARN value to attach to Sumo Logic sources. If this is kept empty, a new IAM role will be created."
  default = {
    create_iam_role = true
    iam_role_arn    = null
  }
}

variable "wait_for_seconds" {
  type        = number
  description = <<EOT
        wait_for_seconds is used to delay sumo logic source creation. This helps persisting IAM role in AWS system.
        Default value is 180 seconds.
        If the AWS IAM role is created outside the module, the value can be decreased to 1 second.
    EOT
  default     = 180
}

variable "aws_resource_tags" {
  description = "Map of tags to apply to all AWS resources provisioned through the Module"
  type        = map(string)
  default     = {}
}