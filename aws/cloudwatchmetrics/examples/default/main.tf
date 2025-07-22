module "cloudwatch_metrics" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/cloudwatchmetrics"

  create_collector          = true
  sumologic_organization_id = var.sumologic_organization_id
  wait_for_seconds          = 20
  aws_resource_tags = local.aws_resource_tags
  source_details = {
        "collector_id": module.cloudwatch_metrics.sumologic_collector.collector.id ,
        "description": "This source is created using Sumo Logic terraform AWS CloudWatch Metrics module to collect AWS Cloudwatch metrics.",
        "fields": {},
        "iam_details": {
            "create_iam_role": true,
            "iam_role_arn": null
        },
        "limit_to_namespaces": ["AWS/EC2", "AWS/ApiGateway", "AWS/ApplicationELB"],
        "tag_filters": [{
          "type" = "TagFilters"
          "namespace" = "AWS/EC2"
          "tags" = ["env=prod;dev"]
        },{
          "type" = "TagFilters"
          "namespace" = "AWS/ApiGateway"
          "tags" = ["env=prod;dev"]
        },{
          "type" = "TagFilters"
          "namespace" = "AWS/ApplicationELB"
          "tags" = ["env=dev"]
        }],
        "limit_to_regions": ["eu-central-1"],
        "paused": false,
        "scan_interval": 300000,
        "source_category": "Labs/aws/cloudwatch/metrics",
        "source_name": "CloudWatch Metrics Source",
        "sumo_account_id": 926226587429
    }  
}
