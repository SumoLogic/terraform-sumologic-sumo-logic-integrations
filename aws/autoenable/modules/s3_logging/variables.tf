variable "auto_enable_logging" {
  description = "S3 - To Enable S3 Audit Logging for new S3 buckets. VPC - To Enable VPC flow logs for new VPC, Subnets and Network Interfaces. ALB - To Enable S3 Logging for new Application Load Balancer. ELB - To Enable S3 logging for new Classic Load Balancer"
  type        = string
  validation {
    condition     = contains(["S3", "VPC", "ALB", "ELB"], var.auto_enable_logging)
    error_message = "Auto enable logging must be one of: S3, VPC, ALB, ELB."
  }
}

variable "auto_enable_resource_options" {
  description = "New - Automatically enables S3 logging for newly created AWS resources to send logs to S3 Buckets. Existing - Automatically enables S3 logging for existing AWS resources. Both - Automatically enables S3 logging for new and existing AWS resources. None - Skips Automatic S3 Logging enable for AWS resources."
  type        = string
  default     = "Both"
  validation {
    condition     = contains(["New", "Existing", "Both", "None"], var.auto_enable_resource_options)
    error_message = "Auto enable resource options must be one of: New, Existing, Both, None."
  }
}

variable "bucket_name" {
  description = "Provide an Existing bucket Name."
  type        = string
}

variable "bucket_prefix" {
  description = "Provide an bucket prefix."
  type        = string
  default     = ""
}

variable "filter_expression" {
  description = "Provide regular expression for matching aws resources. For eg;- 'InstanceType': 't1.micro.*?'|'name': 'Test.*?']|'stageName': 'prod.*?'|'FunctionName': 'Test.*?'|TableName.*?|'LoadBalancerName': 'Test.*?'|'DBClusterIdentifier': 'Test.*?'|'DBInstanceIdentifier': 'Test.*?'"
  type        = string
  default     = ""
}

variable "remove_on_delete_stack" {
  description = "True - To remove S3 logging or Vpc flow logs. False - To keep the S3 logging."
  type        = bool
  default     = true
}

variable "aws_resource_tags" {
  description = "Map of tags to apply to all AWS resources provisioned through the Module"
  type        = map(string)
  default     = {}
}