# Create/Delete Sumo Logic to Jira Cloud Webhook i.e. Connection in Sumo Logic by calling REST API
# https://help.sumologic.com/Beta/Webhook_Connection_for_Jira_Cloud

data "template_file" "data_json_stjc" {
  template = file("${path.module}/sumo_to_jiracloud_webhook.json.tmpl")
  vars = {
    jira_cloud_issuetype  = var.jira_cloud_issuetype
    jira_cloud_priority   = var.jira_cloud_priority
    jira_cloud_projectkey = var.jira_cloud_projectkey
  }
}


# Create/Delete Sumo Logic to Jira Cloud Webhook
resource "sumologic_connection" "jira_cloud_connection" {
  type        = "WebhookConnection"
  name        = "Jira Cloud Webhook"
  description = "Created via Sumo Logic module."
  url         = "${var.jira_cloud_url}/rest/api/2/issue"
  headers = {
    "X-Header" : var.jira_cloud_auth
  }

  default_payload = data.template_file.data_json_stjc.rendered
  webhook_type    = "Jira"
}