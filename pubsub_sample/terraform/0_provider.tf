terraform {
  required_providers {
    google = {
      version = "> 5.9.0"
    }
    google-beta = {
      version = "> 5.9.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.gcp_region
}

provider "google-beta" {
  project = var.project_id
  region  = var.gcp_region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  disable_services_on_destroy = false
  project_id = var.project_id
  activate_apis = [
    "workstations.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "stackdriver.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "clouddeploy.googleapis.com",
    "sourcerepo.googleapis.com",
    "run.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "workstations.googleapis.com",
    "pubsub.googleapis.com",
    "redis.googleapis.com",
    "serviceconsumermanagement.googleapis.com",
    "networkconnectivity.googleapis.com"
  ]
}
