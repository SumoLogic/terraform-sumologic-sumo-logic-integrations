locals {
  project = "some-project-name"
  name    = "sumologic"
}

module "sumologic" {
  source  = "SumoLogic/sumo-logic-integrations/sumologic//gcp/cloudlogging/"
  version = "v1.0.7"

  name        = local.name
  gcp_project = local.project
}
