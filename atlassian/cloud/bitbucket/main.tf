# Create/Delete BitBucket Cloud Source
resource "sumologic_http_source" "bitbucket_cloud" {
  name         = "Bitbucket Cloud"
  category     = var.source_category
  collector_id = var.collector_id
}

# Create/Delete BitBucket to Sumo Logic Webhook
resource "bitbucket_hook" "sumo_bitbucket" {
  count       = length(var.bitbucket_cloud_repos)
  owner       = var.bitbucket_cloud_owner
  repository  = var.bitbucket_cloud_repos[count.index]
  url         = sumologic_http_source.bitbucket_cloud.url
  description = var.bitbucket_cloud_desc
  events      = var.bitbucket_cloud_events
}

# Generate timestamp to add to the folder name.
locals {
  time_stamp = formatdate("DD-MMM-YYYY hh:mm:ss", timestamp())
}

# Install Bitbucket
resource "null_resource" "install_bitbucket_cloud_app" {
  depends_on = [sumologic_http_source.bitbucket_cloud]
  triggers = {
        version = var.app_version
  }

  provisioner "local-exec" {
    command = <<EOT
        curl -s --request POST '${var.sumo_api_endpoint}apps/3b068c67-069e-417e-a855-ff7549a0606d/install' \
            --header 'Accept: application/json' \
            --header 'Content-Type: application/json' \
            -u "${var.sumo_access_id}:${var.sumo_access_key}" \
            --data-raw '{ "name": "Bitbucket - ${local.time_stamp}", "description": "The Sumo Logic App for Bitbucket provides insights into project management to more effectively plan the deployments.", "destinationFolderId": "${var.folder_id}","dataSourceValues": {"bblogsrc": "_sourceCategory = ${var.source_category}" }}'
    EOT
  }
}