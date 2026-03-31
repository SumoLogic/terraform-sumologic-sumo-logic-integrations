locals {

  # sumo aws account ids
  sumo_account_ids = {
    aws        = "926226587429"  # Commercial AWS account
    aws-us-gov = "926226587429"   # GovCloud account
    aws-cn     = "926226587429"   # China account
    aws-eusc   = "052162193518"   # EU Sovereign account
  }

  # Get the default collector name if no collector name is provided.
  collector_name = var.collector_details.collector_name == "SumoLogic CloudWatch Metrics Collector <Random ID>" ? "SumoLogic CloudWatch Metrics Collector ${random_string.aws_random.id}" : var.collector_details.collector_name

}