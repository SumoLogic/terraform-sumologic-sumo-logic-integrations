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
    collector_name = "SumoLogic Elb Collector <Random ID>"
    description    = "This collector is created using Sumo Logic terraform AWS ELB module to collect AWS elb logs."
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
    iam_details = object({
      create_iam_role = bool
      iam_role_arn    = string
    })
    sns_topic_details = object({
      create_sns_topic = bool
      sns_topic_arn    = string
    })
  })
  description = "Provide details for the Sumo Logic ELB source. If not provided, then defaults will be used."
  default = {
    source_name     = "Elb Source"
    source_category = "Labs/aws/elb"
    description     = "This source is created using Sumo Logic terraform AWS elb module to collect AWS elb logs."
    collector_id    = ""
    bucket_details = {
      create_bucket        = true
      bucket_name          = "elb-logs-random-id"
      path_expression      = "*AWSLogs/<ACCOUNT-ID>/elasticloadbalancing/<REGION-NAME>/*"
      force_destroy_bucket = true
    }
    paused               = false
    scan_interval        = 300000
    sumo_account_id      = 926226587429
    cutoff_relative_time = "-1d"
    fields               = {}
    iam_details = {
      create_iam_role = true
      iam_role_arn    = null
    }
    sns_topic_details = {
      create_sns_topic = true
      sns_topic_arn    = null
    }
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

variable "auto_enable_access_logs" {
  type        = string
  description = <<EOT
				New - Automatically enables access logging for newly created ELB resources to collect logs for ELB resources. This does not affect ELB resources already collecting logs.
				Existing - Automatically enables access logging for existing ELB resources to collect logs for ELB resources.
				Both - Automatically enables access logging for new and existing ELB resources.
				None - Skips Automatic access Logging enable for ELB resources.
		  EOT
  validation {
    condition = contains([
      "New",
      "Existing",
      "Both",
    "None", ], var.auto_enable_access_logs)
    error_message = "The value must be one of New, Existing, Both and None."
  }
  default = "Both"
}

variable "app_semantic_version" {
  type        = string
  description = "Provide the latest version of Serverless Application Repository 'sumologic-s3-logging-auto-enable'."
  default = "1.0.17"
}

variable "auto_enable_access_logs_options" {
  type = object({
    bucket_prefix          = string
    auto_enable_logging    = string
    filter                 = string
    remove_on_delete_stack = bool
  })

  description = <<EOT
		filter - provide a regex to filter the ELB for which access logs should be enabled. Empty means all resources. For eg :- 'Type': 'application'|'type': 'application', will enable access logs for Application load balancer only.
		remove_on_delete_stack - provide true if you would like to disable access logging when you destroy the terraform resources.
	EOT

  default = {
    bucket_prefix          = ""
    auto_enable_logging    = ""
    filter                 = ""
    remove_on_delete_stack = true
  }
  validation {
    condition = contains(["ALB", "ELB"], var.auto_enable_access_logs_options.auto_enable_logging)
    error_message = "The value must be one of ALB or ELB."
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