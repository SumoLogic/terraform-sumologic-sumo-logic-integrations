resource "google_project_iam_binding" "sumologic" {
  project = var.gcp_project

  role = "roles/pubsub.publisher"

  members = [
    "serviceAccount:cloud-logs@system.gserviceaccount.com"
  ]
}

resource "google_logging_project_sink" "sumologic" {
  project = var.gcp_project

  name = var.name

  destination = "pubsub.googleapis.com/${google_pubsub_topic.sumologic.id}"

  filter = var.logging_sink_filter
}

resource "google_pubsub_subscription" "sumologic" {
  project = var.gcp_project

  name  = var.name
  topic = google_pubsub_topic.sumologic.name

  ack_deadline_seconds = 20

  push_config {
    push_endpoint = sumologic_gcp_source.this.url
  }
}

resource "google_pubsub_topic" "sumologic" {
  project = var.gcp_project

  name = var.name
}
