# Sumo Logic to Jira Server Webhook - This feature is in Beta. To participate contact your Sumo account executive.
# https://docs.atlassian.com/software/jira/docs/api/REST/7.6.1/#api/2/issue-createIssue
data "template_file" "data_json_stjs" {
  template = file("${path.module}/sumo_to_jiraserver_webhook.json.tmpl")
  vars = {
    jira_server_issuetype  = var.jira_server_issuetype
    jira_server_priority   = var.jira_server_priority
    jira_server_projectkey = var.jira_server_projectkey
  }
}

# Create/Delete Sumo Logic to Jira Server Webhook
resource "sumologic_connection" "jira_server_connection" {
  type        = "WebhookConnection"
  name        = "Jira Server Webhook"
  description = "Created via Sumo Logic module."
  url         = "${var.jira_server_url}/rest/api/2/issue"
  headers = {
    "X-Header" : var.jira_server_auth
  }

  default_payload = data.template_file.data_json_stjs.rendered
  webhook_type    = "Jira"
}