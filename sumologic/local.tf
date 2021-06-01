locals {
  api_endpoint = var.environment == "us1" ? "https://api.sumologic.com/api" : "https://api.${var.environment}.sumologic.com/api"

  folder_path = dirname(dirname(path.cwd))
}