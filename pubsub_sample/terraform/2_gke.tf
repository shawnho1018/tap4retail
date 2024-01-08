module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id                 = var.project_id
  name                       = "lab-cluster"
  regional                   = false
  region                     = var.gcp_region
  zones                      = var.gcp_zones
  create_service_account     = false
  network                    = google_compute_network.custom-network.name
  subnetwork                 = google_compute_subnetwork.custom-subnet.name
  ip_range_pods              = "podrange"
  ip_range_services          = "servicerange"
  http_load_balancing        = true
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = true
  gce_pd_csi_driver          = true
  gcs_fuse_csi_driver        = true
  remove_default_node_pool   = true
  enable_vertical_pod_autoscaling = true
  datapath_provider          = "ADVANCED_DATAPATH"
  enable_binary_authorization = false
  enable_shielded_nodes      = true
  enable_cost_allocation     = true
  enable_network_egress_export = true
  enable_resource_consumption_export = true
  resource_usage_export_dataset_id = "gke_cluster_consumption"
  enable_private_endpoint    = false
  enable_private_nodes       = true
  grant_registry_access      = true
  master_ipv4_cidr_block     = var.master_ipv4_cidr_block
  cluster_dns_provider       = "CLOUD_DNS"
  cluster_dns_scope          = "CLUSTER_SCOPE"
  monitoring_enable_managed_prometheus = true
  gke_backup_agent_config    = true
  monitoring_enabled_components = ["SYSTEM_COMPONENTS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER"]
  release_channel            = "REGULAR"
  gateway_api_channel        = "CHANNEL_STANDARD"
  deletion_protection        = false
  node_pools = [
    {
      name                      = "default-node-pool"
      machine_type              = "e2-standard-8"
      node_locations            = join("," ,var.gcp_zones)
      min_count                 = 1
      max_count                 = 1
      local_ssd_count           = 0
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = true
      enable_gvnic              = false
      auto_repair               = true
      auto_upgrade              = true
      preemptible               = false
      initial_node_count        = 1
    },
  ]
  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

