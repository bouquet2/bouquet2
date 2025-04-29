# bouquet:cluster
variable "talos_version" {
  description = "Talos version"
  type        = string
  default     = "v1.9.2"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.32.4"
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

variable "rr_url" {
  description = "RoundRobin URL"
  type        = string
}

variable "worker_url_internal_base" {
  description = "Internal base URL for workers"
  type        = string
}

variable "worker_url_external_base" {
  description = "External base URL for workers"
  type        = string
}

variable "firewall_rules" {
  description = "Firewall rules"
  type = map(object({
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
    location    = optional(string)
    taints      = list(string)
    image       = optional(string)
  }))
}

variable "control_planes" {
  description = "Control plane definition"
  type = map(object({
    name        = string
    cloud_type  = string
    server_type = string
    location    = optional(string)
    taints      = optional(list(string))
    image       = optional(string)
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

