provider "sumologic" {
	access_id = "<access_id>"
	access_key = "<access_key>"
	environment = "us1"
}

data "sumologic_personal_folder" "personal" {}

resource "sumologic_folder" "app_folder" {
	description = "This is a test folder"
	name = "Test Folder"
	parent_id = data.sumologic_personal_folder.personal.id
}

resource "sumologic_monitor_folder" "tf_monitor_folder" {
  name = "Test Folder for Module"
  description = "Folder for Monitors"
}

module "rds_module" {
  source = "../sumologic"

  access_id   = "<access_id>"
  access_key  = "<access_key>"
  environment = "us1"

  # ********************** Metric Rules ********************** #

  managed_metric_rules = {
    "MetricRuleOne" = {
      metric_rule_name = "MetricRuleOne"
      match_expression = "Namespace=AWS/RDS DBClusterIdentifier=*"
      sleep            = 0
      variables_to_extract = [
        {
          name        = "dbidentifier"
          tagSequence = "$DBClusterIdentifier._1"
        }
      ]
    }
  }

  # ********************** Fields ********************** #

  managed_fields = {
    "FieldOne" = {
      field_name = "fieldone"
      data_type  = "String"
      state      = true
    }
  }

  # ********************** FERs ********************** #

  managed_field_extraction_rules = {
    "FieldExtractionRuleOne" = {
      name             = "FieldExtractionRuleOne"
      scope            = "account=* eventname eventsource \"rds.amazonaws.com\""
      parse_expression = <<EOT
              json "eventSource", "awsRegion", "requestParameters", "responseElements" as eventSource, region, requestParameters, responseElements nodrop
              | where eventSource = "rds.amazonaws.com"
              | "aws/rds" as namespace
              | json field=requestParameters "dBInstanceIdentifier", "resourceName", "dBClusterIdentifier" as dBInstanceIdentifier1, resourceName, dBClusterIdentifier1 nodrop
              | json field=responseElements "dBInstanceIdentifier" as dBInstanceIdentifier3 nodrop | json field=responseElements "dBClusterIdentifier" as dBClusterIdentifier3 nodrop
              | parse field=resourceName "arn:aws:rds:*:db:*" as f1, dBInstanceIdentifier2 nodrop | parse field=resourceName "arn:aws:rds:*:cluster:*" as f1, dBClusterIdentifier2 nodrop
              | if (resourceName matches "arn:aws:rds:*:db:*", dBInstanceIdentifier2, if (!isEmpty(dBInstanceIdentifier1), dBInstanceIdentifier1, dBInstanceIdentifier3) ) as dBInstanceIdentifier
              | if (resourceName matches "arn:aws:rds:*:cluster:*", dBClusterIdentifier2, if (!isEmpty(dBClusterIdentifier1), dBClusterIdentifier1, dBClusterIdentifier3) ) as dBClusterIdentifier
              | if (isEmpty(dBInstanceIdentifier), dBClusterIdentifier, dBInstanceIdentifier) as dbidentifier
              | tolowercase(dbidentifier) as dbidentifier
              | fields region, namespace, dBInstanceIdentifier, dBClusterIdentifier, dbidentifier
      EOT
      enabled          = true
    }
  }

  # ********************** Apps ********************** #

  managed_apps = {
    "RdsApp" = {
      content_json = join("", [dirname(path.cwd), "/terratest/sumologic/testapp.json"])
      folder_id    = sumologic_folder.app_folder.id
    }
  }

  # ********************** Monitors ********************** #

  managed_monitors = {
    "MonitorOne" = {
      monitor_name         = "Monitor One"
      monitor_description  = "This alert fires when the average RDS Aurora buffer cache hit ratio within a 5 minute interval is low (<= 50%). This indicates that a lower percentage of requests were are served by the buffer cache, which could further indicate a degradation in application performance."
      monitor_monitor_type = "Metrics"
      monitor_parent_id    = sumologic_monitor_folder.tf_monitor_folder.id
      monitor_is_disabled  = true
      queries = {
        A = "Namespace=aws/rds metric=BufferCacheHitRatio statistic=Average account=* region=* dbidentifier=* | avg by dbidentifier, namespace, region, account"
      }
      triggers = [
        {
          detection_method = "StaticCondition",
          time_range       = "-5m",
          trigger_type     = "Critical",
          threshold        = 50,
          threshold_type   = "LessThanOrEqual",
          occurrence_type  = "Always",
          trigger_source   = "AnyTimeSeries"
        },
        {
          detection_method = "StaticCondition",
          time_range       = "-5m",
          trigger_type     = "ResolvedCritical",
          threshold        = 50,
          threshold_type   = "GreaterThan",
          occurrence_type  = "Always",
          trigger_source   = "AnyTimeSeries"
        }
      ]
      group_notifications      = false
      connection_notifications = []
      email_notifications      = []
    }
  }
}