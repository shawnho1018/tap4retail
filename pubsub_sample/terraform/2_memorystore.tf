# The following two resources were for memorystore redis cluster mode, which requires PSC to connect to the instance.
# resource "google_network_connectivity_service_connection_policy" "default" {
#   name = "redis-psc-policy"
#   location = var.gcp_region
#   service_class = "gcp-memorystore-redis"
#   description   = "redis service connection policy"
#   network = google_compute_network.custom-network.id
#   psc_config {
#     subnetworks = [google_compute_subnetwork.custom-subnet.id]
#   }
# }

# resource "google_redis_cluster" "cache" {
#   name           = "ha-cluster"
#   shard_count    = 3
#   psc_configs {
#     network = google_compute_network.custom-network.id
#   }
#   region = "asia-east1"
#   replica_count = 1
#   transit_encryption_mode = "TRANSIT_ENCRYPTION_MODE_DISABLED"
#   authorization_mode = "AUTH_MODE_IAM_AUTH"
#   depends_on = [
#     google_network_connectivity_service_connection_policy.default
#   ]

#   lifecycle {
#     prevent_destroy = false
#   }
# }


# MemoryStore (Google Redis) Standard Cluster
resource "google_compute_global_address" "service_range" {
  name          = "address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.custom-network.id
}
resource "google_service_networking_connection" "private_service_connection" {
  network                 = google_compute_network.custom-network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.service_range.name]
}

resource "google_redis_instance" "cache" {
  project        = var.project_id
  name           = "std-redis"
  tier           = "STANDARD_HA"
  memory_size_gb = 1

  location_id             = "asia-east1-a"
  alternative_location_id = "asia-east1-b"

  authorized_network = google_compute_network.custom-network.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  redis_version     = "REDIS_6_X"
  display_name      = "Terraform Test Instance"

  depends_on = [google_service_networking_connection.private_service_connection, module.project-services]

  lifecycle {
    prevent_destroy = false
  }
}

# Configure IAM for GCE Test Instance
# This instance host redis-cli to test memorystore as well as apache website to allow cloudrun to connect to.

# resource "google_service_account" "default" {
#   account_id   = "redis-sa"
#   display_name = "Custom SA for VM Instance"
# }

# resource "google_project_iam_member" "redis-sa" {
#   project = var.project_id
#   role    = "roles/redis.admin"
#   member  = "serviceAccount:${google_service_account.default.email}"
# }

# resource "google_project_iam_member" "db-connector" {
#   project = var.project_id
#   role    = "roles/redis.dbConnectionUser"
#   member  = "serviceAccount:${google_service_account.default.email}"
# }

# resource "google_compute_instance" "default" {
#   name         = "test-instance"
#   machine_type = "e2-medium"
#   zone         = var.gcp_zone
#   tags = ["client"]
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#       labels = {
#         my_label = "value"
#       }
#     }
#   }
#   network_interface {
#     # network = google_compute_network.custom-network.id
#     subnetwork = google_compute_subnetwork.custom-subnet.id
#   }
#   metadata = {
#     foo = "bar"
#   }

#   metadata_startup_script = "apt update && apt install -y redis apache2"

#   service_account {
#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     email  = google_service_account.default.email
#     scopes = ["cloud-platform"]
#   }
# }