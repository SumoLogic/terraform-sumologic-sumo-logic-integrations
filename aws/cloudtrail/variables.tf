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
    collector_name = "SumoLogic CloudTrail Collector <AWS Account Id>"
    description    = "This collector is created using Sumo Logic terraform AWS cloudtrail module to collect AWS cloudtrail logs."
    fields         = {}
  }
}

variable "source_details" {
  type = object({
    source_name     = string
    source_category = string
    collector_id    = string
    description     = string
    bucket_details = object({
      create_bucket        = bool
      bucket_name          = string
      path_expression      = string
      force_destroy_bucket = bool
    })
    paused               = bool
    scan_interval        = string
    sumo_account_id      = number
    cutoff_relative_time = string
    fields               = map(string)
    iam_role_arn         = string
    sns_topic_arn        = string
  })
  description = "Provide details for the Sumo Logic CloudTrail source. If not provided, then defaults will be used."
  default = {
    source_name     = "CloudTrail Source"
    source_category = "Labs/aws/cloudtrail"
    description     = "This source is created using Sumo Logic terraform AWS cloudtrail module to collect AWS cloudtrail logs."
    collector_id    = ""
    bucket_details = {
      create_bucket        = true
      bucket_name          = "cloudtrail-logs-accountid-region"
      path_expression      = "AWSLogs/<ACCCOUNT-ID>/CloudTrail/<REGION-NAME>/*"
      force_destroy_bucket = false
    }
    paused               = false
    scan_interval        = 300000
    sumo_account_id      = 926226587429
    cutoff_relative_time = "-1d"
    fields               = {}
    iam_role_arn         = ""
    sns_topic_arn        = ""
  }
  validation {
    condition     = can(regex("[a-z0-9-.]{3,63}$", var.source_details.bucket_details.bucket_name))
    error_message = "3-63 characters; must contain only lowercase letters, numbers, hyphen or period. For more details - https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html."
  }
  validation {
    condition     = can(regex("-[0-9]{1,}[M|w|d|h|m]{1}$", var.source_details.cutoff_relative_time))
    error_message = "Cut off relative time can be either months (M), weeks (w), days (d), hours (h), or minutes (m). Use 0m to indicate the current time."
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

variable "create_trail" {
  type        = bool
  description = "Provide \"true\" if you would like to create the AWS CloudTrail. If the bucket is created by the module, module by default creates the AWS cloudtrail."
}

variable "cloudtrail_details" {
  type = object({
    name                          = string
    is_multi_region_trail         = bool
    is_organization_trail         = bool
    include_global_service_events = bool
  })
  description = "Provide details for the AWS CloudTrail. If not provided, then defaults will be used."
  default = {
    name                          = "SumoLogic-Terraform-CloudTrail"
    is_multi_region_trail         = false
    is_organization_trail         = false
    include_global_service_events = false
  }
}