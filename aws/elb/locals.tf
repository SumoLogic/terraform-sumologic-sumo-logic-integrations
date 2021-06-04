locals {

  aws_account_id = data.aws_caller_identity.current.account_id

  aws_region = data.aws_region.current.id

  # Get the default collector name if no collector name is provided.
  collector_name = var.collector_details.collector_name == "SumoLogic Elb Collector <AWS Account Id>" ? "SumoLogic Elb Collector ${local.aws_account_id}" : var.collector_details.collector_name

  # Get the default bucket name when no bucket is provided and create_bucket is true.
  bucket_name = var.source_details.bucket_details.create_bucket && var.source_details.bucket_details.bucket_name == "elb-logs-accountid-region" ? "elb-logs-${local.aws_account_id}-${local.aws_region}" : var.source_details.bucket_details.bucket_name

  # Create IAM role condition if no IAM ROLE ARN is provided.
  create_iam_role = var.source_details.iam_role_arn != "" ? false : true

  # Create SNS topic condition if no SNS topic arn is provided.
  create_sns_topic = var.source_details.sns_topic_arn != "" ? false : true

  # Auto enable should be called if input is anything other than None.
  auto_enable_access_logs = var.auto_enable_access_logs != "None" ? true : false

  # If we create the bucket, then get the default PATH expression.
  logs_path_expression = var.source_details.bucket_details.create_bucket ? "*AWSLogs/${local.aws_account_id}/elasticloadbalancing/${local.aws_region}/*" : var.source_details.bucket_details.path_expression
  
  region_to_elb_account_id = {
    "us-east-1"      = "127311923021",
    "us-east-2"      = "033677994240",
    "us-west-1"      = "027434742980",
    "us-west-2"      = "797873946194",
    "af-south-1"     = "098369216593",
    "ca-central-1"   = "985666609251",
    "eu-central-1"   = "054676820928",
    "eu-west-1"      = "156460612806",
    "eu-west-2"      = "652711504416",
    "eu-south-1"     = "635631232127",
    "eu-west-3"      = "009996457667",
    "eu-north-1"     = "897822967062",
    "ap-east-1"      = "754344448648",
    "ap-northeast-1" = "582318560864",
    "ap-northeast-2" = "600734575887",
    "ap-northeast-3" = "383597477331",
    "ap-southeast-1" = "114774131450",
    "ap-southeast-2" = "783225319266",
    "ap-south-1"     = "718504428378",
    "me-south-1"     = "076674570225",
    "sa-east-1"      = "507241528517",
    "us-gov-west-1"  = "048591011584",
    "us-gov-east-1"  = "190560391635",
    "cn-north-1"     = "638102146993",
    "cn-northwest-1" = "037604701340"
  }
}