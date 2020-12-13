# Create/Delete Github Source
resource "sumologic_http_source" "github" {
  name         = "Github"
  category     = var.source_category
  fields       = { "_convertHeadersToFields" = "true" }
  collector_id = var.collector_id
}

# Repository Level Webhook
resource "github_repository_webhook" "github_sumologic_repo_webhook" {
  count      = "${var.github_repo_webhook_create}" ? length(var.github_repository_names) : 0
  repository = var.github_repository_names[count.index]

  configuration {
    url          = sumologic_http_source.github.url
    content_type = "json"
    insecure_ssl = false
  }

  active = true

  events = var.github_repo_events
}

# Organization Level Webhook
resource "github_organization_webhook" "github_sumologic_org_webhook" {
  count = "${var.github_org_webhook_create}" ? 1 : 0

  configuration {
    url          = sumologic_http_source.github.url
    content_type = "json"
    insecure_ssl = false
  }

  active = true

  events = var.github_org_events
}

# Generate timestamp to add to the folder name.
locals {
  time_stamp = formatdate("DD-MMM-YYYY hh:mm:ss", timestamp())
}

# Install Github App
resource "null_resource" "install_github_app" {
  depends_on = [sumologic_http_source.github]
  triggers = {
        version = var.app_version
  }

  provisioner "local-exec" {
    command = <<EOT
        curl -s --request POST '${var.sumo_api_endpoint}/v1/apps/86289912-b909-426e-8154-bda55b9ee902/install' \
            --header 'Accept: application/json' \
            --header 'Content-Type: application/json' \
            -u ${var.sumo_access_id}:${var.sumo_access_key} \
            --data-raw '{ "name": "Github - ${local.time_stamp}", "description": "The Sumo Logic App for GitHub connects to your GitHub repository at the Organization or Repository level, and ingests GitHub events via a webhook.", "destinationFolderId": "${var.folder_id}","dataSourceValues": {"paramId123": "_sourceCategory = ${var.source_category}"}}'
    EOT
  }
}