# Jira Cloud
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
  description = "Sumo Logic Jira Cloud Source Category"
  default     = "Atlassian/Jira/Cloud"
}
variable "folder_id" {
  type        = string
  description = "Sumo Logic Content Folder ID"
}
variable "jira_cloud_jql" {
  type        = string
  description = "Jira Cloud JQL query"
  default     = ""
}
variable "jira_cloud_events" {
  type        = list
  description = "Jira Cloud Events"
  default = ["jira:issue_created", "jira:issue_updated", "jira:issue_deleted",
    "issue_property_set", "issue_property_deleted", "comment_created", "comment_updated", "comment_deleted",
    "worklog_created", "worklog_updated", "worklog_deleted",
    "attachment_created", "attachment_deleted", "issuelink_created", "issuelink_deleted",
    "project_created", "project_updated", "project_deleted",
    "jira:version_released", "jira:version_unreleased", "jira:version_created", "jira:version_moved", "jira:version_updated", "jira:version_deleted", "jira:version_deleted",
    "user_created", "user_updated", "user_deleted",
    "option_voting_changed", "option_watching_changed", "option_watching_changed", "option_unassigned_issues_changed", "option_subtasks_changed", "option_attachments_changed", "option_issuelinks_changed", "option_timetracking_changed",
    "sprint_created", "sprint_deleted", "sprint_updated", "sprint_started", "sprint_closed",
    "board_created", "board_updated", "board_deleted", "board_configuration_changed",
  "jira_expression_evaluation_failed"]
}

variable "app_version" {
  type        = string
  description = "App Version"
  default     = "1.0"
}