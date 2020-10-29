# Jira Server
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
  description = "Sumo Logic Jira Server Source Category"
  default     = "Atlassian/Jira/Events"
}
variable "folder_id" {
  type        = string
  description = "Sumo Logic Content Folder ID"
}
variable "jira_server_jql" {
  type        = string
  description = "Jira Server JQL query"
  default     = ""
}
variable "jira_server_events" {
  type        = list
  description = "Jira Server Events"
  default = ["jira:issue_created", "jira:issue_updated", "jira:issue_deleted",
    "jira:worklog_updated", "issuelink_created", "issuelink_deleted",
    "worklog_created", "worklog_updated", "worklog_deleted", "project_created", "project_updated", "project_deleted",
    "jira:version_released", "jira:version_unreleased", "jira:version_created", "jira:version_moved", "jira:version_updated", "jira:version_deleted", "jira:version_deleted",
    "user_created", "user_updated", "user_deleted",
    "option_voting_changed", "option_watching_changed", "option_unassigned_issues_changed", "option_subtasks_changed", "option_attachments_changed", "option_issuelinks_changed", "option_timetracking_changed",
    "sprint_created", "sprint_deleted", "sprint_updated", "sprint_started", "sprint_closed",
  "board_created", "board_updated", "board_deleted", "board_configuration_changed"]
}
variable "jira_server_access_logs_sourcecategory" {
  type        = string
  description = "Jira Server Access Logs Source Category"
  default     = "Atlassian/Jira/Server*"
}
variable "app_version" {
  type        = string
  description = "App Version"
  default     = "1.0"
}