resource "random_string" "aws_random" {
  length  = 10
  upper   = false
  special = false
}

module "loggroup_auto_enable_module" {
  source = "git::https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations.git//aws/autoenable/modules/loggroup?ref=fy27q2"

 # Destination Configuration
  destination_arn_type  = "Kinesis"
  destination_arn_value = "arn:aws:firehose:ap-southeast-1:285573938264:deliverystream/PUT-HTP-4ntpO"

  # Log Group Configuration
  log_group_pattern = "^$"
  log_group_tags    = "Environment=prod,Project=logging"

  # Optional Configuration
  use_existing_logs = "true"
  role_arn          = "arn:aws:iam::285573938264:role/KinesisLogsRoleCW"

  aws_resource_tags = {
    Environment = "prod"
    Project     = "logging"
  }
}