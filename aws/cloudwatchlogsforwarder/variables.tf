variable "email_id" {
  type        = string
  default     = "test@gmail.com"
  description = "Email for receiving alerts. A confirmation email is sent after the deployment is complete. It can be confirmed to subscribe for alerts."

  validation {
    condition     = can(regex("\\w+@\\w+\\.\\w+", var.email_id))
    error_message = "Email address must be valid."
  }
}

variable "workers" {
  type        = number
  default     = 4
  description = "Number of lambda function invocations for Cloudwatch logs source Dead Letter Queue processing."
}

variable "log_format" {
  type        = string
  default     = "Others"
  description = "Service for Cloudwatch logs source."

  validation {
    condition     = contains(["VPC-RAW", "VPC-JSON", "Others"], var.log_format)
    error_message = "Log format service must be be one of VPC-RAW, VPC-JSON, or Others."
  }
}

variable "include_log_group_info" {
  type        = bool
  default     = true
  description = "Enable loggroup/logstream values in logs."
}

variable "log_stream_prefix" {
  type        = list(string)
  default     = []
  description = "LogStream name prefixes to filter by logStream. Please note this is separate from a logGroup. This is used only to send certain logStreams within a Cloudwatch logGroup(s). LogGroups still need to be subscribed to the created Lambda function regardless of this input value."
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
    collector_name = "SumoLogic CloudWatch Logs Collector <Random ID>"
    description    = "This collector is created using Sumo Logic terraform AWS CloudWatch Logs forwarder to collect AWS cloudwatch logs."
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
  description = "Provide details for the Sumo Logic HTTP source. If not provided, then defaults will be used."
  default = {
    source_name     = "CloudWatch Logs Source"
    source_category = "Labs/aws/cloudwatch"
    description     = "This source is created using Sumo Logic terraform AWS CloudWatch Logs forwarder to collect AWS cloudwatch logs."
    collector_id    = ""
    fields          = {}
  }
}

variable "app_semantic_version" {
  type        = string
  description = "Provide the latest version of Serverless Application Repository 'sumologic-loggroup-connector'."
  default = "1.0.14"
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
    tags_filter = string
  })

  description = <<EOT
		filter - Enter regex for matching logGroups. Regex will check for the name.
        tags_filter - Enter comma separated key value pairs for filtering logGroups using tags. Ex KeyName1=string,KeyName2=string. This is optional leave it blank if tag based filtering is not needed.
        Visit https://help.sumologic.com/docs/send-data/collect-from-other-data-sources/autosubscribe-arn-destination/#configuringparameters
	EOT

  default = {
    filter = "lambda"
    tags_filter = ""
  }
}

variable "aws_resource_tags" {
  description = "Map of tags to apply to all AWS resources provisioned through the Module"
  type        = map(string)
}