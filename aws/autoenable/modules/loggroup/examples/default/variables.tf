variable "destination_arn_type" {
  type        = string
  description = "Lambda - When the destination ARN for subscription filter is an AWS Lambda Function. Kinesis - When the destination ARN for subscription filter is an Kinesis or Amazon Kinesis data firehose stream."
  default     = "Lambda"

  validation {
    condition     = contains(["Lambda", "Kinesis"], var.destination_arn_type)
    error_message = "Must be either 'Lambda' or 'Kinesis'."
  }
}

variable "destination_arn_value" {
  type        = string
  default     = "arn:aws:lambda:us-east-1:123456789000:function:TestLambda"
  description = "Enter Destination ARN like Lambda function, Kinesis stream. For more information, visit - https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilters.html"
}

variable "log_group_pattern" {
  type        = string
  default     = "Test"
  description = "Enter regex for matching logGroups"
}

variable "use_existing_logs" {
  type        = string
  default     = "true"
  description = "Select true for subscribing existing logs"

  validation {
    condition     = contains(["true", "false"], var.use_existing_logs)
    error_message = "Must be either 'true' or 'false'."
  }
}

variable "log_group_tags" {
  type        = list(string)
  default     = []
  description = "Enter comma separated keyvalue pairs for filtering logGroups using tags. Ex KeyName1=string,KeyName2=string. This is optional leave it blank if tag based filtering is not needed."
}

variable "role_arn" {
  type        = string
  default     = ""
  description = "Enter AWS IAM Role arn in case the destination is Kinesis Firehose stream."
}

variable "aws_resource_tags" {
  description = "Map of tags to apply to all AWS resources provisioned through the Module"
  type        = map(string)
  default     = {}
}