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

variable "workers" {
    description = "Worker definition"
    type = map(object({
      name         = string
      cloud_type   = string
      server_type  = string
      location     = optional(string) # Shouldn't be required for OCI
      taints       = list(string)
      image        = optional(string) # Shouldn't be required for OCI

      # OCI-specific attributes (optional)
      ocpus          = optional(number)
      memory_in_gb   = optional(number)
      boot_volume_in_gb = optional(number)
    }))
}

variable "control_planes" {
    description = "Control plane definition"
    type = map(object({
      name         = string
      cloud_type   = string
      server_type  = string
      location     = optional(string) # Shouldn't be required for OCI
      taints       = optional(list(string))
      image        = optional(string) # Shouldn't be required for OCI
      
      # OCI-specific attributes (optional)
      ocpus          = optional(number)
      memory_in_gb   = optional(number)
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
}

# bouquet:oci
