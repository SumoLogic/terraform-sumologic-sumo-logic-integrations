module "cloudwatch_metrics" {
  source = "git::https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations.git//aws/cloudwatchmetrics"

  create_collector          = true
  sumologic_organization_id = var.sumologic_organization_id
  wait_for_seconds          = 180
  source_details = {
        "collector_id": module.cloudwatch_metrics.sumologic_collector.collector.id ,
        "description": "This source is created using Sumo Logic terraform AWS CloudWatch Metrics module to collect AWS Cloudwatch metrics.",
        "fields": {},
        "iam_details": {
            "create_iam_role": true,
            "iam_role_arn": null
        },
        "limit_to_namespaces": ["aws/ec2"],
        "limit_to_regions": ["eu-central-1"],
        "paused": false,
        "scan_interval": 300000,
        "source_category": "Labs/aws/cloudwatch/metrics",
        "source_name": "CloudWatch Metrics Source",
        "sumo_account_id": 926226587429
    }  
}
