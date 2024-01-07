variable "project_id" {
  type        = string
  description = "The GCP Project ID to apply this config to."
}
variable "gcp_region" {
  type        = string
  description = "The GCP region to apply this config to."
}
variable "gcp_zones" {
  type        = list(string)
  description = "The GCP zones to apply this config to."
}

variable "gcp_zone" {
  type        = string
  description = "The GCP zones to apply this config to."
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "master ipv4 block to connect to GKE control plane"
}
