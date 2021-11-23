locals {
  sumologic_collector_name = var.sumologic_collector_name == null ? var.name : var.sumologic_collector_name
  sumologic_source_name    = var.sumologic_source_name == null ? var.name : var.sumologic_source_name
}
resource "sumologic_collector" "this" {
  name        = local.sumologic_collector_name
  description = var.sumologic_description

  category = var.sumologic_category
  fields   = var.sumologic_collector_fields
}

resource "sumologic_gcp_source" "this" {
  name        = local.sumologic_source_name
  description = var.sumologic_description

  collector_id = sumologic_collector.this.id
  category     = var.sumologic_category
}
