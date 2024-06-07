# Jira Service Desk
variable "install_sumo_to_jiraservicedesk_webhook" {
  type        = string
  description = "Install Sumo to Jira Service Desk webhook"
}
variable "jira_servicedesk_url" {
  type        = string
  description = "Jira Service Desk URL"
}
variable "jira_servicedesk_issuetype" {
  type        = string
  description = "Jira Service Desk Issue Type"
  default     = "Bug"
}
variable "jira_servicedesk_priority" {
  type        = string
  description = "Jira Service Desk Issue Priority"
  default     = "3"
}
variable "jira_servicedesk_projectkey" {
  type        = string
  description = "Jira Service Desk Project Key"
}
variable "jira_servicedesk_auth" {
  type        = string
  description = "Jira Service Desk Auth. https://help.sumologic.com/Beta/Webhook_Connection_for_Jira_Cloud#prerequisite"
}