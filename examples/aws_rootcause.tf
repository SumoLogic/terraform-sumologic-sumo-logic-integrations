module "rootcause" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/rootcause"

  create_collector = true
  collector_details = {
    "collector_name" = "Root Cause Collector",
    "description"    = "This is a new description.",
    "fields" = {
      "TestCollector" = "MyValue"
    }
  }

  create_inventory_source = true
  inventory_source_details = {
    "source_name"     = "Inventory Source",
    "source_category" = "Labs/inventory",
    "description"     = "This source is inventory source.",
    "paused"          = false,
    "scan_interval"   = 60000,
    "fields" = {
      "TestCollector" = "MyValue"
    },
    "sumo_account_id"   = "926226587429",
    "collector_id"      = "",
    "iam_role_arn"      = "",
    limit_to_regions    = ["us-east-1"],
    limit_to_namespaces = ["AWS/SNS"]
  }

  create_xray_source = true
  xray_source_details = {
    "source_name"     = "XRay Source",
    "source_category" = "Labs/xray",
    "description"     = "This source is xray source.",
    "paused"          = false,
    "scan_interval"   = 60000,
    "fields" = {
      "TestCollector" = "MyValue"
    },
    "sumo_account_id" = "926226587429",
    "collector_id"    = "",
    "iam_role_arn"    = "",
    limit_to_regions  = ["us-east-1"]
  }
  sumologic_organization_id = "0000000000123456"

  iam_details = {
    "create_iam_role" = true,
    "iam_role_arn"    = ""
  }
}