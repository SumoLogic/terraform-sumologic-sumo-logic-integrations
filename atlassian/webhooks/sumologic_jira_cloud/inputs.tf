# Jira Cloud
variable "jira_cloud_url" {
  type        = string
  description = "Jira Cloud URL"
}
variable "jira_cloud_issuetype" {
  type        = string
  description = "Jira Cloud Issue Type"
  default     = "Bug"
}
variable "jira_cloud_priority" {
  type        = string
  description = "Jira Cloud Issue Priority"
  default     = "3"
}
variable "jira_cloud_projectkey" {
  type        = string
  description = "Jira Cloud Project Key"
}
variable "jira_cloud_auth" {
  type        = string
  description = "Jira Cloud Auth. https://help.sumologic.com/Beta/Webhook_Connection_for_Jira_Cloud#prerequisite"
}