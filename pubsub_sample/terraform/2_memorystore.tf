# resource "google_compute_subnetwork" "redis_subnet" {
#   name          = "redis-subnet"
#   ip_cidr_range = "10.0.0.248/29"
#   region        = var.gcp_region
#   network       = google_compute_network.custom-network.id
# }

resource "google_network_connectivity_service_connection_policy" "default" {
  name = "redis-psc-policy"
  location = var.gcp_region
  service_class = "gcp-memorystore-redis"
  description   = "redis service connection policy"
  network = google_compute_network.custom-network.id
  psc_config {
    subnetworks = [google_compute_subnetwork.custom-subnet.id]
  }
}

resource "google_service_account" "default" {
  account_id   = "redis-sa"
  display_name = "Custom SA for VM Instance"
}

resource "google_redis_cluster" "cache" {
  name           = "ha-cluster"
  shard_count    = 3
  psc_configs {
    network = google_compute_network.custom-network.id
  }
  region = "asia-east1"
  replica_count = 1
  transit_encryption_mode = "TRANSIT_ENCRYPTION_MODE_DISABLED"
  authorization_mode = "AUTH_MODE_IAM_AUTH"
  depends_on = [
    google_network_connectivity_service_connection_policy.default
  ]

  lifecycle {
    prevent_destroy = false
  }
}

# Configure IAM for GCE Test Instance
resource "google_project_iam_member" "redis-sa" {
  project = var.project_id
  role    = "roles/redis.admin"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "db-connector" {
  project = var.project_id
  role    = "roles/redis.dbConnectionUser"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "google_compute_instance" "default" {
  name         = "test-instance"
  machine_type = "e2-medium"
  zone         = var.gcp_zone
  tags = ["client"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    # network = google_compute_network.custom-network.id
    subnetwork = google_compute_subnetwork.custom-subnet.id
  }
  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "apt update && apt install -y redis"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}