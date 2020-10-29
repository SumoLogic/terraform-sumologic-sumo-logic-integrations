# Create/Delete Jira Cloud Source
resource "sumologic_http_source" "jira_cloud" {
  name         = "Jira Cloud"
  category     = var.source_category
  collector_id = var.collector_id
}

# Create/Delete Jira Cloud to Sumo Logic Webhook
resource "jira_webhook" "sumo_jira" {
  name   = "Sumologic Hook"
  url    = sumologic_http_source.jira_cloud.url
  jql    = var.jira_cloud_jql
  events = var.jira_cloud_events # See https://developer.atlassian.com/cloud/jira/platform/webhooks/ for supported events
}

# Generate timestamp to add to the folder name.
locals {
  time_stamp = formatdate("DD-MMM-YYYY hh:mm:ss", timestamp())
}

# Install Jira Cloud App in Sumo Logic
resource "null_resource" "install_jira_cloud_app" {
  depends_on = [sumologic_http_source.jira_cloud]
  triggers = {
        version = var.app_version
  }

  provisioner "local-exec" {
    command = <<EOT
        curl -s --request POST '${var.sumo_api_endpoint}apps/019757ca-3b08-457c-bd15-7239f1ab66c9/install' \
            --header 'Accept: application/json' \
            --header 'Content-Type: application/json' \
            -u "${var.sumo_access_id}:${var.sumo_access_key}" \
            --data-raw '{ "name": "Jira Cloud - ${local.time_stamp}", "description": "The Sumo Logic App for Jira Cloud provides insights into project management issues that enable you to more effectively plan, assign, track, report, and manage work across multiple teams.", "destinationFolderId": "${var.folder_id}","dataSourceValues": {"jiralogsrc": "_sourceCategory = ${var.source_category}" }}'
    EOT
  }
}