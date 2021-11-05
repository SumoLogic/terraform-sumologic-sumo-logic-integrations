variable "gcp_project" {
  description = "GCP project ID."
  type        = string
}

variable "logging_sink_filter" {
  description = "Logging filter for the GCP sink."
  type        = string
  default     = null
}

variable "name" {
  description = "Names that will be assigned to resources."
  type        = string
}

variable "sumologic_category" {
  description = "The category description for the collector/source."
  type        = string
  default     = "gcp"
}

variable "sumologic_collector_fields" {
  description = "A Map containing key/value pairs."
  type        = map(any)
  default     = null
}

variable "sumologic_collector_name" {
  description = "Name for the collector."
  type        = string
  default     = null
}

variable "sumologic_collector_timezone" {
  description = "The time zone to use for this collector."
  type        = string
  default     = null
}

variable "sumologic_description" {
  description = "The description of the created resources collector/source."
  type        = string
  default     = null
}

variable "sumologic_source_name" {
  description = "Name for the GCP source."
  type        = string
  default     = null
}