# Jira Server
variable "jira_server_url" {
  type        = string
  description = "Jira Server URL"
}
variable "jira_server_issuetype" {
  type        = string
  description = "Jira Server Issue Type"
  default     = "Bug"
}
variable "jira_server_priority" {
  type        = string
  description = "Jira Server Issue Priority"
  default     = "3"
}
variable "jira_server_projectkey" {
  type        = string
  description = "Jira Server Project Key"
}
variable "jira_server_auth" {
  type        = string
  description = "Jira Server Auth. https://help.sumologic.com/Beta/Webhook_Connection_for_Jira_Server#prerequisite"
}