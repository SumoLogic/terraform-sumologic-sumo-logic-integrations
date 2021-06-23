locals {

  aws_account_id = data.aws_caller_identity.current.account_id

  aws_region = data.aws_region.current.id

  # Get the default collector name if no collector name is provided.
  collector_name = var.collector_details.collector_name == "SumoLogic RootCause Collector <Random ID>" ? "SumoLogic RootCause Collector ${random_string.aws_random.id}" : var.collector_details.collector_name

  # Create inventory source
  create_inventory_source = var.create_inventory_source

  # Create XRAY source
  create_xray_source = var.create_xray_source
}