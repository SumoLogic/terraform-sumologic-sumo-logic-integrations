# Create/Delete Sumo Logic to Jira Service Desk Webhook i.e. Connection in Sumo Logic by calling REST API
# https://help.sumologic.com/Beta/Webhook_Connection_for_Jira_Service_Desk
data "template_file" "data_json_stjsd" {
  template = file("${path.module}/sumo_to_jiraservicedesk_webhook.json.tmpl")
  vars = {
    jira_servicedesk_issuetype  = var.jira_servicedesk_issuetype
    jira_servicedesk_priority   = var.jira_servicedesk_priority
    jira_servicedesk_projectkey = var.jira_servicedesk_projectkey
  }
}

# Create/Delete Sumo Logic to Jira Service Desk Webhook
resource "sumologic_connection" "jira_service_desk_connection" {
  count       = var.create_jira_service_desk_webhook_connection ? 1 : 0
  type        = "WebhookConnection"
  name        = "Jira Service Desk Webhook"
  description = "Created via Sumo Logic module."
  url         = "${var.jira_servicedesk_url}/rest/api/2/issue"
  headers = {
    "X-Header" : var.jira_servicedesk_auth
  }

  default_payload = data.template_file.data_json_stjsd.rendered
  webhook_type    = "Jira"
}