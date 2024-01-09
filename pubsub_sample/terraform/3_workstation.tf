resource "google_workstations_workstation_cluster" "default" {
  provider               = google-beta
  workstation_cluster_id = "momo-workstation-cluster"
  network                = google_compute_network.custom-network.id
  subnetwork             = google_compute_subnetwork.custom-subnet.id
  location               = var.gcp_region

  labels = {
    "label" = "momo-dev"
  }

  annotations = {
    label-one = "packing"
  }
}
resource "google_workstations_workstation_config" "default" {
  provider               = google-beta
  workstation_config_id  = "workstation-config"
  workstation_cluster_id = google_workstations_workstation_cluster.default.workstation_cluster_id
  location               = var.gcp_region

  idle_timeout = "600s"
  running_timeout = "21600s"

  replica_zones = var.gcp_zones
  annotations = {
    label-one = "value-one"
  }

  labels = {
    "label" = "key"
  }

  host {
    gce_instance {
      machine_type                = "e2-standard-4"
      boot_disk_size_gb           = 35
      disable_public_ip_addresses = true
    }
  }
  persistent_directories {
    mount_path = "/home"
    gce_pd {
      size_gb        = 200
      fs_type        = "ext4"
      disk_type      = "pd-standard"
      reclaim_policy = "DELETE"
    }
  }
}
