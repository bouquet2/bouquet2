# bouquet:cluster
variable "talos_version" {
  description = "Talos version"
  type        = string
  default     = "v1.9.2"
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
  default     = "bouquet2"
}

variable "controlplane_url" {
  description = "Control plane URL"
  type        = string
}

variable "firewall_rules" {
  description = "Firewall rules"
  type        = map(object({
    name        = string
    description = string
    protocol    = string
    direction   = string
    port        = number
    cloud_type  = string
    source_ips  = list(string)
  }))
}

variable "workers" {
  description = "Worker definition"
  type = map(object({
    name        = string
    cloud_type  = string
    server_type = string
    location    = optional(string) # Shouldn't be required for OCI
    taints      = list(string)
    image       = optional(string) # Shouldn't be required for OCI

    # OCI-specific attributes (optional)
    ocpus             = optional(number)
    memory_in_gb      = optional(number)
    boot_volume_in_gb = optional(number)
  }))
}

variable "control_planes" {
  description = "Control plane definition"
  type = map(object({
    name        = string
    cloud_type  = string
    server_type = string
    location    = optional(string) # Shouldn't be required for OCI
    taints      = optional(list(string))
    image       = optional(string) # Shouldn't be required for OCI

    # OCI-specific attributes (optional)
    ocpus             = optional(number)
    memory_in_gb      = optional(number)
    boot_volume_in_gb = optional(number)
  }))
}

# bouquet:tailnet
variable "tailnet" {
  description = "Tailnet name"
  type        = string
}

variable "tailnet_oauth_client_id" {
  description = "OAuth client ID"
  sensitive   = true
  type        = string
}

variable "tailnet_oauth_client_secret" {
  description = "OAuth client secret"
  sensitive   = true
  type        = string
}

# bouquet:cloudflare
variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  sensitive   = true
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  sensitive   = true
  type        = string
}

# bouquet:hetzner
variable "hcloud_token" {
  description = "Hetzner Cloud token"
  sensitive   = true
  type        = string
  default     = null
}

# bouquet:oci
variable "oci_tenancy_ocid" {
  description = "OCI tenancy OCID"
  sensitive   = true
  type        = string
  default     = null
}

variable "oci_user_ocid" {
  description = "OCI user OCID"
  sensitive   = true
  type        = string
  default     = null
}

variable "oci_fingerprint" {
  description = "OCI fingerprint"
  sensitive   = true
  type        = string
  default     = null
}

variable "oci_private_key_path" {
  description = "OCI private key path"
  sensitive   = true
  type        = string
  default     = null
}

variable "oci_region" {
  description = "OCI region"
  type        = string
  default     = null
}
