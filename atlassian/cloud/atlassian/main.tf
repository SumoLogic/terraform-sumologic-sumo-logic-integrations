# Generate timestamp to add to the folder name.
locals {
  time_stamp = formatdate("DD-MMM-YYYY hh:mm:ss", timestamp())
}

# Install Atlassian Solution App
resource "null_resource" "install_atlassian_app" {

  triggers = {
        version = var.app_version
  }

  provisioner "local-exec" {
    command = <<EOT
        curl -s --request POST '${var.sumo_api_endpoint}apps/332afd45-eb37-4d65-85b5-21eaead37f6b/install' \
            --header 'Accept: application/json' \
            --header 'Content-Type: application/json' \
            -u "${var.sumo_access_id}:${var.sumo_access_key}" \
            --data-raw '{ "name": "Atlassian - ${local.time_stamp}", "description": "The Atlassian App provides insights into critical data across Atlassian applications, including Jira Cloud, Jira Server, Bitbucket, Atlassian Access, and OpsGenie from one pane-of-glass in a seamless dashboard experience.", "destinationFolderId": "${var.folder_id}","dataSourceValues": {"oglogsrc": "_sourceCategory = ${var.opsgenie_source_category}","jiralogsrc": "(_sourceCategory = ${var.jira_cloud_source_category} or _sourceCategory = ${var.jira_server_webhooks_source_category})","bblogsrc": "_sourceCategory = ${var.bitbucket_source_category}" }}'
    EOT
  }
}