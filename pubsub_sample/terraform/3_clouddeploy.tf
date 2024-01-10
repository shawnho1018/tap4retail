resource "google_clouddeploy_target" "primary" {
  location          = var.gcp_region
  name              = "dev"
  deploy_parameters = {}
  description       = "basic description"

  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
  }

  project          = var.project_id
  require_approval = false

  run {
    location = "projects/${var.project_id}/locations/${var.gcp_region}"
  }

  annotations = {
  }

  labels = {
    my_first_label = "example-label-1"
    my_second_label = "example-label-2"
  }
  provider = google-beta
}

resource "google_clouddeploy_delivery_pipeline" "primary" {
  location    = var.gcp_region
  name        = "demo-pipeline"
  description = "basic description"
  project     = var.project_id

  serial_pipeline {
    stages {
      deploy_parameters {
        values = {
          deployParameterKey = "deployParameterValue"
        }
        match_target_labels = {}
      }
      profiles  = ["dev"]
      target_id = google_clouddeploy_target.primary.name
    }
  }

  annotations = {
    my_first_annotation = "example-annotation-1"
  }

  labels = {
    my_first_label = "example-label-1"
  }
  provider    = google-beta
}