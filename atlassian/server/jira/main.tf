# Create/Delete Jira Server Source
resource "sumologic_http_source" "jira_server" {
  name         = "Jira Server"
  category     = var.source_category
  collector_id = var.collector_id
}

# Create/Delete Jira Server to Sumo Logic Webhook
resource "jira_webhook" "sumo_jira_server" {
  name   = "Sumologic Hook"
  url    = sumologic_http_source.jira_server.url
  jql    = var.jira_server_jql
  events = var.jira_server_events # See https://developer.atlassian.com/server/jira/platform/webhooks/ for supported events
}

# Generate timestamp to add to the folder name.
locals {
  time_stamp = formatdate("DD-MMM-YYYY hh:mm:ss", timestamp())
}

# Install Jira Server
resource "null_resource" "install_jira_server_app" {
  depends_on = [sumologic_http_source.jira_server]

  triggers = {
        version = var.app_version
  }

  provisioner "local-exec" {
    command = <<EOT
        curl -s --request POST '${var.sumo_api_endpoint}apps/ec905b32-e514-4c63-baac-0efa3b3a2109/install' \
            --header 'Accept: application/json' \
            --header 'Content-Type: application/json' \
            -u "${var.sumo_access_id}:${var.sumo_access_key}" \
            --data-raw '{ "name": "Jira - ${local.time_stamp}", "description": "The Sumo Logic App for Jira provides insight into Jira usage, request activity, issues, security, sprint events, and user events.", "destinationFolderId": "${var.folder_id}","dataSourceValues": {"jiralogsrc": "_sourceCategory = ${var.jira_server_access_logs_sourcecategory}", "jirawebhooklogsrc": "_sourceCategory = ${var.source_category}" }}'
    EOT
  }
}