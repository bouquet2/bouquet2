# Cluster name, control plane URL and worker URL configuration
cluster_name = "bouquet2"

# Round Robin URL for the control plane
# Control planes will always use Round Robin.
controlplane_url = "controlplane.alpha.internal.kreato.dev"

# Base URL for Worker nodes
# Example: rose-new would be rose-new.internal.kreato.dev
worker_url_internal_base = "alpha.internal.kreato.dev"

# Example: rose-new would be rose-new.kreato.dev
worker_url_external_base = "alpha.kreato.dev"

# Round Robin URL configuration
# This is the URL that you should use to expose services to the outside world.
rr_url = "rr.alpha.internal.kreato.dev"

# Control plane and worker node configuration
control_planes = {
  1 = {
    name        = "rose-new"
    cloud_type  = "hetzner",
    server_type = "cax21",
    location    = "hel1",
    image       = "233953667",
    taints      = [],
  }
}

workers = {
  1 = {
    name        = "lily-new"
    cloud_type  = "hetzner",
    server_type = "cax21",
    location    = "fsn1",
    image       = "233953667",
    taints      = [],
  },
  2 = {
    name        = "iris"
    cloud_type  = "hetzner",
    server_type = "cax11",
    location    = "nbg1",
    image       = "233953667",
    taints      = [],
  }
}

# Firewall rules
firewall_rules = {
  1 = {
    name        = "HTTPS (TCP)",
    description = "Allow HTTPS traffic",
    protocol    = "tcp",
    direction   = "in",
    port        = "443",
    cloud_type  = "both",
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  },
  2 = {
    name        = "HTTPS (UDP)",
    description = "Allow HTTPS traffic",
    protocol    = "udp",
    direction   = "in",
    port        = "443",
    cloud_type  = "both",
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  },
  3 = {
    name        = "Tailscale (UDP)",
    description = "Allow direct Tailscale traffic",
    protocol    = "udp",
    direction   = "in",
    port        = "41641",
    cloud_type  = "both",
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}
