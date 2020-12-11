# AWS CloudTrail Sumo Logic
variable "sumo_access_id" {
  type        = string
  description = "Sumo Logic Access ID"
}
variable "sumo_access_key" {
  type        = string
  description = "Sumo Logic Access Key"
}
variable "sumo_external_id" {
  type        = string
  description = "Provide the Sumo Logic external ID - https://help.sumologic.com/03Send-Data/Sources/02Sources-for-Hosted-Collectors/Amazon-Web-Services/Grant-Access-to-an-AWS-Product#iam-role"
}
variable "folder_id" {
  type        = string
  description = "Sumo Logic Content Folder ID"
}
variable "aws_resource_name" {
  type        = string
  description = "AWS S3 Bucket, AWS SNS Topic, AWS CloudTrail, AWS IAM Role and IAM Policy will be created with the provided name."
  default = "sumo-logic-terraform-cloudtrail"
}
variable "sumo_api_endpoint" {
  type        = string
  description = "Sumo Logic Endpoint"
  default     = "https://api.sumologic.com/api/v1/"
}
variable "sumo_collector_name" {
  type        = string
  description = "Provide a Collector Name."
  default = "sumo-logic-terraform-cloudtrail"
}
variable "sumo_source_name" {
  type        = string
  description = "Provide a CloudTrail Source Name."
  default = "sumo-logic-terraform-cloudtrail"
}
variable "sumo_source_category" {
  type        = string
  description = "Provide a CloudTrail Source Category."
  default = "Labs/CloudTrail"
}
variable "sumo_aws_account_id" {
  type        = number
  description = "Provide the Sumo Logic AWS Account ID. Get the Account ID - https://help.sumologic.com/03Send-Data/Sources/02Sources-for-Hosted-Collectors/Amazon-Web-Services/Grant-Access-to-an-AWS-Product#iam-role"
  default = 926226587429
}
variable "app_version" {
  type        = string
  description = "App Version"
  default     = "1.0"
}