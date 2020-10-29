# Sumo Logic Provider
provider "sumologic" {
  access_id   = "<SUMO_ACCESS_ID>"
  access_key  = "<SUMO_ACCESS_KEY>"
  environment = "us1"
}

# Create/Delete Collector
resource "sumologic_collector" "atlassian_collector" {
  name     = "Atlassian"
  category = "Atlassian"
}

# Create Folder for all Jira Apps
data "sumologic_personal_folder" "personalFolder" {}
resource "sumologic_folder" "folder" {
  name        = "Atlassian"
  description = "Atlassian Applications"
  parent_id   = data.sumologic_personal_folder.personalFolder.id
  depends_on  = [sumologic_collector.atlassian_collector]
}