resource "google_compute_subnetwork" "custom-subnet" {
  name          = "custom-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.custom-network.id
  secondary_ip_range {
    range_name    = "podrange"
    ip_cidr_range = "192.168.16.0/20"
  }
  secondary_ip_range {
    range_name    = "servicerange"
    ip_cidr_range = "192.168.32.0/24"
  }
}

resource "google_compute_network" "custom-network" {
  name                    = "momo-network"
  auto_create_subnetworks = false
}

resource "google_compute_router" "nat-router" {
  name    = "nat-router"
  network = google_compute_network.custom-network.name
  region  = google_compute_subnetwork.custom-subnet.region
}
# Only need when GCE is used to test MemoryStore
# Otherwise, remove this
resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.custom-network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = [
    "0.0.0.0/0",
  ]
  target_tags = ["client"]
}

resource "google_compute_router_nat" "nat" {
  name                               = "intranet-snat"
  router                             = google_compute_router.nat-router.name
  region                             = google_compute_router.nat-router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}