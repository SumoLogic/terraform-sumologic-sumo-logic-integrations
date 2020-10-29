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
variable "collector_id" {
  type        = string
  description = "Sumo Logic Collector ID"
}
variable "source_category" {
  type        = string
  description = "Sumo Logic Bitbucket Source Category"
  default     = "Atlassian/Bitbucket"
}
variable "folder_id" {
  type        = string
  description = "Sumo Logic Content Folder ID"
}
variable "bitbucket_cloud_owner" {
  type        = string
  description = "Bitbucket Cloud Owner"
}
variable "bitbucket_cloud_desc" {
  type        = string
  description = "Bitbucket Cloud Webhook Description"
  default     = "Send events to Sumo Logic"
}
variable "bitbucket_cloud_repos" {
  type        = list
  description = "Bitbucket Cloud Repositories"
  default     = []
}
variable "bitbucket_cloud_events" {
  type        = list
  description = "Bitbucket Cloud Events"
  default = [
    "repo:push", "repo:fork", "repo:updated", "repo:commit_comment_created"
    , "repo:commit_status_updated", "repo:commit_status_created"
    , "issue:created", "issue:updated", "issue:comment_created"
    , "pullrequest:created", "pullrequest:updated", "pullrequest:approved", "pullrequest:unapproved", "pullrequest:fulfilled", "pullrequest:rejected"
    , "pullrequest:comment_created", "pullrequest:comment_updated", "pullrequest:comment_deleted"
  ]
}
variable "app_version" {
  type        = string
  description = "App Version"
  default     = "1.0"
}