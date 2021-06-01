# ************* 1. Create multiple Metric Rules based on input parameters. ************* #

resource "null_resource" "MetricRules" {

  for_each = var.managed_metric_rules
  triggers = {
    name               = each.value.metric_rule_name
    matchExpression    = each.value.match_expression
    variablesToExtract = jsonencode(each.value.variables_to_extract)
    sleep              = each.value.sleep
    access_id          = var.access_id
    access_key         = var.access_key
    api_endpoint       = local.api_endpoint
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOT
        sleep ${self.triggers.sleep}s
        curl -s --request POST '${local.api_endpoint}/v1/metricsRules' \
            --header 'Accept: application/json' \
            --header 'Content-Type: application/json' \
            -u ${var.access_id}:${var.access_key} \
            --data-raw '{"name": "${self.triggers.name}", "matchExpression": "${self.triggers.matchExpression}", "variablesToExtract": ${self.triggers.variablesToExtract}}'
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
        sleep ${self.triggers.sleep}s
        curl -s --request DELETE '${self.triggers.api_endpoint}/v1/metricsRules/${self.triggers.name}' \
            --header 'Accept: application/json' \
            --header 'Content-Type: application/json' \
            -u ${self.triggers.access_id}:${self.triggers.access_key}
    EOT
  }
}

# ************* 2. Create Multiple Fields based on input parameters. ************* #

resource "sumologic_field" "SumoLogicFields" {
  for_each = var.managed_fields

  field_name = each.value.field_name
  data_type  = each.value.data_type
  state      = each.value.state ? "Enabled" : "Disabled"
}

# ************* 3. Create Multiple Field Extraction Rules based on input parameters. ************* #

resource "sumologic_field_extraction_rule" "SumoLogicFieldExtractionRules" {
  depends_on = [sumologic_field.SumoLogicFields]
  for_each   = var.managed_field_extraction_rules

  enabled          = each.value.enabled
  name             = each.value.name
  parse_expression = each.value.parse_expression
  scope            = each.value.scope
}

# ************* 4. Create Apps based on input Parameters. ************* #

resource "sumologic_content" "SumoLogicApps" {
  for_each = var.managed_apps

  config    = file(join("", [local.folder_path, each.value.content_json]))
  parent_id = each.value.folder_id
}

# ************* 5. Create Monitors based on input Parameters. ************* #

module "SumoLogicMonitors" {
  for_each = var.managed_monitors

  source                   = "SumoLogic/sumo-logic-monitor/sumologic"
  monitor_name             = each.value.monitor_name
  monitor_description      = each.value.monitor_description
  monitor_monitor_type     = each.value.monitor_monitor_type
  monitor_parent_id        = each.value.monitor_parent_id
  monitor_is_disabled      = each.value.monitor_is_disabled
  queries                  = each.value.queries
  triggers                 = each.value.triggers
  group_notifications      = each.value.group_notifications
  connection_notifications = each.value.connection_notifications
  email_notifications      = each.value.email_notifications
}

