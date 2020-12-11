# Pagerduty
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
  description = "Sumo Logic Pagerduty Source Category"
  default     = "Pagerduty"
}
variable "folder_id" {
  type        = string
  description = "Sumo Logic Content Folder ID"
}
variable "pagerduty_services_pagerduty_webhooks" {
  type        = list
  description = "List of Pagerduty Service IDs"
  default     = []
}
variable "app_version" {
  type        = string
  description = "App Version"
  default     = "1.0"
}