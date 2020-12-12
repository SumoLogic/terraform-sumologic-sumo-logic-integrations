# Create/Delete Pagerduty Source
resource "sumologic_http_source" "pagerduty" {
  name         = "Pagerduty"
  category     = var.source_category
  collector_id = var.collector_id
}

data "pagerduty_extension_schema" "webhook" {
  name = "Generic V2 Webhook"
}

# Create Webhook in Pagerduty
resource "pagerduty_extension" "sumologic_extension" {
  count             = length(var.pagerduty_services_pagerduty_webhooks) > 0 ? length(var.pagerduty_services_pagerduty_webhooks) : 0
  name              = "Sumo Logic Webhook"
  endpoint_url      = sumologic_http_source.pagerduty.url
  extension_schema  = data.pagerduty_extension_schema.webhook.id
  extension_objects = [var.pagerduty_services_pagerduty_webhooks[count.index]]
}

data "pagerduty_vendor" "sumologic" {
  name = "Sumo Logic"
}

# Generate timestamp to add to the folder name.
locals {
  time_stamp = formatdate("DD-MMM-YYYY hh:mm:ss", timestamp())
}

# Install Pagerduty App
resource "null_resource" "install_pagerduty_app" {
  depends_on = [sumologic_http_source.pagerduty]
  triggers = {
        version = var.app_version
  }

  provisioner "local-exec" {
    command = <<EOT
        curl -s --request POST '${var.sumo_api_endpoint}/v1/apps/589857e0-e4c1-4165-8212-f656899a3b95/install' \
            --header 'Accept: application/json' \
            --header 'Content-Type: application/json' \
            -u ${var.sumo_access_id}:${var.sumo_access_key} \
            --data-raw '{ "name": "Pagerduty V2 - ${local.time_stamp}", "description": "The Sumo Logic App for PagerDuty V2 collects incident messages from your PagerDuty account via a webhook, and displays that incident data in pre-configured Dashboards, so you can monitor and analyze the activity of your PagerDuty account and Services.", "destinationFolderId": "${var.folder_id}","dataSourceValues": {"logsrcpd": "_sourceCategory = ${var.source_category}"}}'
    EOT
  }
}
