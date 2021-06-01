variable "environment" {
  type        = string
  description = "Enter au, ca, de, eu, jp, us2, in, fed or us1. Visit https://help.sumologic.com/APIs/General-API-Information/Sumo-Logic-Endpoints-and-Firewall-Security"

  validation {
    condition = contains([
      "au",
      "ca",
      "de",
      "eu",
      "jp",
      "us1",
      "us2",
      "in",
    "fed"], var.environment)
    error_message = "The value must be one of au, ca, de, eu, jp, us1, us2, in, or fed."
  }
}

variable "access_id" {
  type        = string
  description = "Sumo Logic Access ID. Visit https://help.sumologic.com/Manage/Security/Access-Keys#Create_an_access_key"

  validation {
    condition     = can(regex("\\w+", var.access_id))
    error_message = "The SumoLogic access ID must contain valid characters."
  }
}

variable "access_key" {
  type        = string
  description = "Sumo Logic Access Key."

  validation {
    condition     = can(regex("\\w+", var.access_key))
    error_message = "The SumoLogic access key must contain valid characters."
  }
}

variable "managed_metric_rules" {
  type = map(object({
    metric_rule_name = string
    match_expression = string
    sleep            = number
    variables_to_extract = list(object({
      name        = string
      tagSequence = string
    }))
  }))
  default     = {}
  description = "The list of metric rules to manage within the Sumo Logic AWS Observability solution."
}

variable "managed_fields" {
  type = map(object({
    field_name = string
    data_type  = string
    state      = bool
  }))
  default     = {}
  description = "The list of Fields to manage within the Sumo Logic AWS Observability Solution"
}

variable "managed_field_extraction_rules" {
  type = map(object({
    name             = string
    parse_expression = string
    scope            = string
    enabled          = bool
  }))
  default     = {}
  description = "The list of Field Extraction Rules to manage within the Sumo Logic AWS Observability Solution"
}

variable "managed_apps" {
  type = map(object({
    folder_id    = string
    content_json = string
  }))
  default     = {}
  description = "The list of Application to manage within the Sumo Logic AWS Observability Solution"
}

variable "managed_monitors" {
  type = map(object({
    monitor_name         = string
    monitor_description  = string
    monitor_monitor_type = string
    monitor_parent_id    = string
    monitor_is_disabled  = bool
    queries              = map(string)
    triggers = list(object({
      threshold_type   = string
      threshold        = string
      time_range       = string
      occurrence_type  = string
      trigger_source   = string
      trigger_type     = string
      detection_method = string
    }))
    connection_notifications = list(object(
      {
        connection_type       = string,
        connection_id         = string,
        payload_override      = string,
        run_for_trigger_types = list(string)
      }
    ))
    email_notifications = list(object(
      {
        connection_type       = string,
        recipients            = list(string),
        subject               = string,
        time_zone             = string,
        message_body          = string,
        run_for_trigger_types = list(string)
      }
    ))
    group_notifications = bool
  }))
  default     = {}
  description = "The list of Monitors to manage within the Sumo Logic AWS Observability Solution"
}