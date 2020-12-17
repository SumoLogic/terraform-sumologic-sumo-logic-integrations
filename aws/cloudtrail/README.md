# AWS CloudTrail

## Purpose

This module installs [Sumo Logic CloudTrail applications](https://help.sumologic.com/07Sumo-Logic-Apps/01Amazon_and_AWS/AWS_CloudTrail) in Sumo Logic.

Apps installed are:
- AWS CloudTrail
- PCI Compliance for AWS CloudTrail
- CIS AWS Foundations Benchmark

## Requirements

* [Terraform](https://www.terraform.io/downloads.html) >= 0.13.0
* Null >= 2.1
* SumoLogic >= 2.1.0

## Module Declaration

This module requires Sumo Logic External Id and Folder id as explained [here](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations#prerequisites-for-using-modules).

```shell
module "sumologic-cloudtrail-apps" {
  source = "SumoLogic/sumo-logic-integrations/sumologic//aws/cloudtrail"
  sumo_access_id                       = "<SUMO_ACCESS_ID>"
  sumo_access_key                      = "<SUMO_ACCESS_KEY>"
  sumo_external_id                     = "<SUMO_EXTERNAL_ID>"
  aws_resource_name                    = "sumo-logic-terraform-cloudtrail"
  sumo_api_endpoint                    = "https://api.sumologic.com/api/v1/"
  sumo_collector_name                  = "sumo-logic-terraform-cloudtrail"
  sumo_source_name                     = "sumo-logic-terraform-cloudtrail"
  sumo_source_category                 = "AWS/CloudTrail"
  sumo_aws_account_id                  = "926226587429"
  folder_id                            = sumologic_folder.folder.id
  app_version                          = "1.0"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
|sumo_access_id|[Sumo Logic Access ID](https://help.sumologic.com/Manage/Security/Access-Keys)|string||yes
|sumo_access_key|[Sumo Logic Access Key](https://help.sumologic.com/Manage/Security/Access-Keys)|string||yes
|sumo_external_id|[Sumo Logic External ID](https://help.sumologic.com/03Send-Data/Sources/02Sources-for-Hosted-Collectors/Amazon-Web-Services/Grant-Access-to-an-AWS-Product#iam-role)|string||yes
|aws_resource_name|AWS S3 Bucket, AWS SNS Topic, AWS CloudTrail, AWS IAM Role and IAM Policy will be created with the provided name|string|sumo-logic-terraform-cloudtrail|no
|sumo_api_endpoint|[Sumo Logic API Endpoint](https://help.sumologic.com/APIs/General-API-Information/Sumo-Logic-Endpoints-and-Firewall-Security)|string|https://api.sumologic.com/api/v1/|yes
|folder_id|Sumo Logic Folder ID|string||yes
|sumo_collector_name|Provide a Collector Name|string|sumo-logic-terraform-cloudtrail|no
|sumo_source_name|Provide a CloudTrail Source Name|string|sumo-logic-terraform-cloudtrail|no
|sumo_source_category|Provide a CloudTrail Source Category|string|AWS/CloudTrail|no
|sumo_aws_account_id|Provide the Sumo Logic AWS Account ID. Get the Account ID - [Visit](https://help.sumologic.com/03Send-Data/Sources/02Sources-for-Hosted-Collectors/Amazon-Web-Services/Grant-Access-to-an-AWS-Product#iam-role)|string|926226587429|no
|app_version|The app_version input parameter can be used to install a new copy of the app. When the app_version field is changed, it will force Terraform to install a new app folder with the current timestamp.|String|1.0|no