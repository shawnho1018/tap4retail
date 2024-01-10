resource "google_compute_instance" "vm_instance_public" {
  name         = "cast-cloud-vm"
  machine_type = "n2-standard-2"
  zone         = var.gcp_zone
  tags         = ["rdp","bastion"]
  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2022"
    }
  }

  network_interface {
    network       = google_compute_network.custom-network.name
    subnetwork    = google_compute_subnetwork.custom-subnet.name
    access_config { }
  }
}

resource "google_compute_firewall" "bastionbost-allow-rdp" {
    name = "bastionbost-allow-rdp"
    network = google_compute_network.custom-network.name
    target_tags = ["bastion"]
    source_ranges = [
        "0.0.0.0/0",
    ]
    allow {
        protocol = "tcp"
        ports    = ["3389"]
    }
}