# Bitbucket
variable "sumo_access_id" {
  type        = string
  description = "Sumo Logic Access ID"
}
variable "sumo_access_key" {
  type        = string
  description = "Sumo Logic Access Key"
}
variable "sumo_api_endpoint" {
  type        = string
  description = "Sumo Logic Endpoint"
  default     = "https://api.sumologic.com/api/v1/"
}
variable "folder_id" {
  type        = string
  description = "Sumo Logic Content Folder ID"
}
variable "opsgenie_source_category" {
  type        = string
  description = "Opsgenie Source Category"
  default     = "Atlassian/Opsgenie"
}
variable "jira_cloud_source_category" {
  type        = string
  description = "Jira Cloud Webhooks Source Category"
  default     = "Atlassian/Jira/Cloud"
}
variable "jira_server_webhooks_source_category" {
  type        = string
  description = "Jira Server Webhooks Source Category"
  default     = "Atlassian/Jira/Events"
}
variable "bitbucket_source_category" {
  type        = string
  description = "Bitbucket Cloud Source Category"
  default     = "Atlassian/Bitbucket"
}
variable "app_version" {
  type        = string
  description = "App Version"
  default     = "1.0"
}