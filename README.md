# terraform-sumologic-sumo-logic-integrations

Configure Sumo Logic Applications and Connections using Terraform modules.
The modules configure/create the following resources:
- A source under the specified collector for the integration in Sumo Logic.
- App dashboards in the specified folder in Sumo Logic.
- Connections in Sumo Logic.
- Webhook configurations in JIRA, Bitbucket, Pagerduty or other chosen systems.
- Resources in cloud systems such as AWS.

## Getting Started

#### Requirements

* [Terraform 0.13+](https://www.terraform.io/downloads.html)
* [curl](https://curl.haxx.se/download.html) for App installations.
* [Sumo Logic Terraform Provider](https://registry.terraform.io/providers/SumoLogic/sumologic/latest)
* [Null Terraform Provider](https://registry.terraform.io/providers/hashicorp/null/latest).
* Respective Terraform providers based on selections.

    Create a `providers.tf` file and add the requirements in the following format:

    ```shell
    terraform {
      required_version = ">= 0.13"

      required_providers {
        null = {
          version = "~> 2.1"
        }
        sumologic = {
          source  = "sumologic/sumologic"
          version = ">= 2.31.0, < 3.0.0"
        }
        jira = {
          source  = "fourplusone/jira"
          version = "~> 0.1.14"
        }

      }
    }
    ```

#### Sumo Logic Provider

```shell
provider "sumologic" {
  access_id   = "<SUMOLOGIC ACCESS ID>"
  access_key  = "<SUMOLOGIC ACCESS KEY>"
  environment = "<SUMOLOGIC DEPLOYMENT>"
}
```
You can also define these values in `terraform.tfvars`.

#### REST Api Provider

Sumo Logic REST Api provider configuration is required for App installations and is needed for all integrations involving App configuration and installation:

```shell
provider "restapi" {
  alias                = "sumo"
  uri                  = "<SUMOLOGIC ENDPOINT URI>"
  write_returns_object = true
  username             = "<SUMOLOGIC ACCESS ID>"
  password             = "<SUMOLOGIC ACCESS KEY>"
  headers              = { Content-Type = "application/json" }
}
```
You can also define these values in `terraform.tfvars`.

#### Prerequisites for using Modules

All App integrations need a collector and a folder where the App should be installed.
Sumo Logic Connections do not need a collector or folder.

Configure the collector resource as below:

```shell
resource "sumologic_collector" "sumo_collector" {
  name     = "SumoLogic Integrations"
  category = "SumoLogic"
}
```

In the module declaration, pass the collector id as `sumologic_collector.sumo_collector.id`.

Configure a folder as below:

```shell
data "sumologic_personal_folder" "personalFolder" {}
resource "sumologic_folder" "folder" {
  name        = "SumoLogic Applications"
  description = "SumoLogic Applications Folder"
  parent_id   = data.sumologic_personal_folder.personalFolder.id
  depends_on  = [sumologic_collector.sumo_collector]
}
```

In the module declaration, pass the folder id as `sumologic_folder.folder.id`.

#### Module Declaration Example

##### Jira Cloud

```shell
module "sumologic-jira-cloud-app" {
  source            = "SumoLogic/sumo-logic-integrations/sumologic//atlassian/cloud/jira"
  version           = "{revision}"

  sumo_access_id    = "<SUMOLOGIC ACCESS ID>"
  sumo_access_key   = "<SUMOLOGIC ACCESS KEY>"
  sumo_api_endpoint = "<SUMOLOGIC ENDPOINT URI>"
  collector_id      = sumologic_collector.sumo_collector.id
  source_category   = "Atlassian/Cloud/Jira"
  folder_id         = sumologic_folder.folder.id
  jira_cloud_jql    = ""                                           # Optional
  jira_cloud_events = ["jira:issue_created", "jira:issue_updated"] # Optional. By default all events are configured.
  app_version       = "1.0"
}
```

See respective module readme and examples for more details.

## Modules

- Atlassian
  - Cloud
      - [Jira](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/atlassian/cloud/jira)
      - [Bitbucket](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/atlassian/cloud/bitbucket)
      - [Atlassian](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/atlassian/cloud/atlassian/)
  - Server
      - [Jira](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/atlassian/server/jira)
  - Sumo Logic Connections
      - [Jira Cloud](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/atlassian/webhooks/sumologic_jira_cloud)
      - [Jira Server](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/atlassian/webhooks/sumologic_jira_server)
      - [Jira Service Desk](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/atlassian/webhooks/sumologic_jira_service_desk)
- AWS
  - [CloudTrail](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/aws/cloudtrail)
- [Github](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/github)
- [Pagerduty](https://github.com/SumoLogic/terraform-sumologic-sumo-logic-integrations/tree/master/pagerduty)

