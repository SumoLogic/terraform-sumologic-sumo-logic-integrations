# terraform-sumologic-integrations

Configure Sumo Logic Applications and Connections using Terraform modules.
The modules configure/create the following resources:
- A source under the specified collector for the integration in Sumo Logic.
- App dashboards in the specified folder in Sumo Logic.
- Webhook configurations in JIRA, Bitbucket or other chosen systems.

## Getting Started

#### Requirements

* [Terraform 0.13+](https://www.terraform.io/downloads.html)
* [curl](https://curl.haxx.se/download.html) for App installations.

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
resource "sumologic_collector" "sumo_atlassian_collector" {
  name     = "SumoLogic Atlassian"
  category = "Atlassian"
}
```

In the module declaration, pass the collector id as `sumologic_collector.sumo_atlassian_collector.id`.

Configure a folder as below:

```shell
data "sumologic_personal_folder" "personalFolder" {}
resource "sumologic_folder" "folder" {
  name        = "SumoLogic Atlassian"
  description = "SumoLogic Atlassian Applications"
  parent_id   = data.sumologic_personal_folder.personalFolder.id
  depends_on  = [sumologic_collector.sumo_atlassian_collector]
}
```

In the module declaration, pass the folder id as `sumologic_folder.folder.id`.

#### Module Declaration Example

##### Jira Cloud

```shell
module "sumologic-jira-cloud-app" {
  source = "github.com/SumoLogic/sumologic-terraform-integrations//atlassian/cloud/jira"
  sumo_access_id    = "<SUMOLOGIC ACCESS ID>"
  sumo_access_key   = "<SUMOLOGIC ACCESS KEY>"
  sumo_api_endpoint = "<SUMOLOGIC ENDPOINT URI>"
  collector_id      = sumologic_collector.sumo_atlassian_collector.id
  source_category   = "Atlassian/Cloud/Jira"
  folder_id         = sumologic_folder.folder.id
  jira_cloud_jql    = ""                                           # Optional
  jira_cloud_events = ["jira:issue_created", "jira:issue_updated"] # Optional. By default all events are configured.
  #  version = "{revision}"
}
```

See respective module readme and examples for more details.