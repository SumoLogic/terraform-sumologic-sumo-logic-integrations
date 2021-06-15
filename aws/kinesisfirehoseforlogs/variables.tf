variable "create_bucket" {
  type        = bool
  description = "Provide \"true\" if you would like to create AWS S3 bucket to store logs. Provide \"bucket_details\" if set to \"false\"."
  default     = true
}

variable "bucket_details" {
  type = object({
    bucket_name          = string
    force_destroy_bucket = bool
  })
  description = "Provide details for the AWS S3 bucket. If not provided, existing will be used."
  default = {
    bucket_name          = "sumologic-kinesis-firehose-logs-accountid-region"
    force_destroy_bucket = true
  }
}

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
    collector_name = "SumoLogic Kinesis Firehose for Logs Collector <AWS Account Id>"
    description    = "This collector is created using Sumo Logic terraform AWS Kinesis Firehose for logs module to collect AWS cloudwatch logs."
    fields         = {}
  }
}

variable "source_details" {
  type = object({
    source_name     = string
    source_category = string
    collector_id    = string
    description     = string
    fields          = map(string)
  })
  description = "Provide details for the Sumo Logic Kinesis Firehose for Logs source. If not provided, then defaults will be used."
  default = {
    source_name     = "Kinesis Firehose for Logs Source"
    source_category = "Labs/aws/cloudwatch/logs"
    description     = "This source is created using Sumo Logic terraform AWS Kinesis Firehose for logs module to collect AWS Cloudwatch logs."
    collector_id    = ""
    fields          = {}
  }
}

variable "auto_enable_logs_subscription" {
  type        = string
  description = <<EOT
				New - Automatically subscribes new log groups to send logs to Sumo Logic.
				Existing - Automatically subscribes existing log groups to send logs to Sumo Logic.
				Both - Automatically subscribes new and existing log groups.
				None - Skips Automatic subscription.
		  EOT
  validation {
    condition = contains([
      "New",
      "Existing",
      "Both",
    "None", ], var.auto_enable_logs_subscription)
    error_message = "The value must be one of New, Existing, Both and None."
  }
  default = "Both"
}

variable "auto_enable_logs_subscription_options" {
  type = object({
    filter = string
  })

  description = <<EOT
		filter - Enter regex for matching logGroups. Regex will check for the name. Visit https://help.sumologic.com/03Send-Data/Collect-from-Other-Data-Sources/Auto-Subscribe_AWS_Log_Groups_to_a_Lambda_Function#Configuring_parameters
	EOT

  default = {
    filter = "lambda"
  }
}

