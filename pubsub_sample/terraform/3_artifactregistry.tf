resource "google_artifact_registry_repository" "momo-repo" {
  location      = var.gcp_region
  repository_id = "momo-docker-registry"
  description   = "docker registry in Taiwan"
  format        = "DOCKER"
}