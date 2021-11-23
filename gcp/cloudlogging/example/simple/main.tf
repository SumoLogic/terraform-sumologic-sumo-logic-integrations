locals {
  project = "some-project-name"
  name    = "sumologic"
}

module "sumologic" {
  source = "../.."

  name        = local.name
  gcp_project = local.project

}