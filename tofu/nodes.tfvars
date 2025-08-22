# Cluster name, control plane URL and worker URL configuration
cluster_name = "bouquet2"

# Round Robin URL for the control plane
# Control planes will always use Round Robin.
controlplane_url = "controlplane.internal.krea.to"

# Base URL for Worker nodes
# Example: rose-new would be rose-new.internal.kreato.dev
worker_url_internal_base = "internal.krea.to"

# Example: rose-new would be rose-new.kreato.dev
worker_url_external_base = "krea.to"

# Round Robin URL configuration
# This is the URL that you should use to expose services to the outside world.
rr_url = "lb.krea.to"

# This is the URL that you should use to expose internal services.
rr_internal_url = "lb.internal.krea.to"

# Talos version (initial)
talos_version = "v1.10.0"

# Kubernetes version (initial)
kubernetes_version = "v1.33.0"

# Control plane and worker node configuration
control_planes = {
  1 = {
    name        = "rose"
    cloud_type  = "hetzner",
    server_type = "cax21",
    location    = "hel1",
    image       = "233953667",
    taints      = [],
  }
}

workers = {
  1 = {
    name        = "lily"
    cloud_type  = "hetzner",
    server_type = "cax21",
    location    = "fsn1",
    image       = "233953667",
    taints      = [],
  },
  2 = {
    name        = "iris"
    cloud_type  = "hetzner",
    server_type = "cax21",
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
  },
  4 = {
    name        = "Cilium WireGuard (UDP)",
    description = "Allow direct Cilium WireGuard traffic",
    protocol    = "udp",
    direction   = "in",
    port        = "51871",
    cloud_type  = "both",
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  },
  5 = {
    name        = "NodePort (TCP)",
    description = "Allow Kubernetes NodePort TCP range",
    protocol    = "tcp",
    direction   = "in",
    port        = "30000-32767",
    cloud_type  = "both",
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  },
  6 = {
    name        = "NodePort (UDP)",
    description = "Allow Kubernetes NodePort UDP range",
    protocol    = "udp",
    direction   = "in",
    port        = "30000-32767",
    cloud_type  = "both",
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}
