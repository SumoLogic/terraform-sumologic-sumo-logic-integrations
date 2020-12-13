# Github
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
  description = "Sumo Logic Github Source Category"
  default     = "Github"
}
variable "folder_id" {
  type        = string
  description = "Sumo Logic Content Folder ID"
}
variable "github_repository_names" {
  type        = list
  description = "Github Repositories"
  default     = []
}
variable "github_repo_events" {
  type        = list
  description = "Github Repository Events"
  default     = ["check_run", "check_suite", "commit_comment", "create", "delete", "deploy_key", "deployment",
  "deployment_status", "fork",
  "gollum", "issue_comment", "issues", "label", "member", "meta", "milestone", "package", "page_build", "ping", "project_card",
  "project_column", "project", "public", "pull_request", "pull_request_review", "pull_request_review_comment",
"push", "release", "repository", "repository_import", "repository_vulnerability_alert", "star", "status", "team_add", "watch"]
}
variable "github_org_events" {
  type        = list
  description = "Github Organization Events"
  default     = ["check_run", "check_suite", "commit_comment", "create", "delete", "deploy_key", "deployment",
  "deployment_status", "fork", "gollum", "issue_comment", "issues", "label", "member",
  "membership", "meta", "milestone", "organization", "org_block", "package", "page_build", "ping", "project_card",
  "project_column", "project", "public", "pull_request", "pull_request_review", "pull_request_review_comment",
"push", "release", "repository", "repository_import", "repository_vulnerability_alert", "star", "status", "team", "team_add", "watch"]
}
variable "github_org_webhook_create" {
  type        = string
  description = "Create Webhooks at Organization Level"
  default     = "false"
}
variable "github_repo_webhook_create" {
  type        = string
  description = "Create Webhooks at Repository Level"
  default     = "true"
}
variable "app_version" {
  type        = string
  description = "App Version"
  default     = "1.0"
}