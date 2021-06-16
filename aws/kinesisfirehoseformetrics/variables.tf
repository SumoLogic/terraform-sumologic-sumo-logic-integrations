variable "create_bucket" {
  type        = bool
  description = "Provide \"true\" if you would like to create AWS S3 bucket to store failed logs. Provide \"bucket_details\" if set to \"false\"."
  default     = true
}

variable "bucket_details" {
  type = object({
    bucket_name          = string
    force_destroy_bucket = bool
  })
  description = "Provide details for the AWS S3 bucket. If not provided, existing will be used."
  default = {
    bucket_name          = "sumologic-kinesis-firehose-metrics-random-id"
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
    collector_name = "SumoLogic Kinesis Firehose for Metrics Collector <Random ID>"
    description    = "This collector is created using Sumo Logic terraform AWS Kinesis Firehose for metrics module to collect AWS cloudwatch metrics."
    fields         = {}
  }
}

variable "source_details" {
  type = object({
    source_name         = string
    source_category     = string
    collector_id        = string
    description         = string
    sumo_account_id     = number
    limit_to_namespaces = list(string)
    fields              = map(string)
    iam_role_arn        = string
  })
  description = "Provide details for the Sumo Logic Kinesis Firehose for Metrics source. If not provided, then defaults will be used."
  default = {
    source_name         = "Kinesis Firehose for Metrics Source"
    source_category     = "Labs/aws/cloudwatch/metrics"
    collector_id        = ""
    description         = "This source is created using Sumo Logic terraform AWS Kinesis Firehose for metrics module to collect AWS Cloudwatch metrics."
    sumo_account_id     = 926226587429
    limit_to_namespaces = []
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

