# Cluster name and control plane URL
cluster_name     = "bouquet2"
controlplane_url = "controlplane.internal.kreato.dev"

# Control plane and worker node configuration
control_planes = {
  1 = {
    name        = "rose-new"
    cloud_type  = "hetzner",
    server_type = "cax11",
    location    = "hel1",
    image       = "233700094",
    taints      = [],
  }
}

workers = {
  1 = {
    name        = "lily-new"
    cloud_type  = "hetzner",
    server_type = "cax21",
    location    = "fsn1",
    image       = "233700094",
    taints      = [],
  },
  2 = {
    name              = "tulip-new"
    cloud_type        = "oci",
    server_type       = "VM.Standard.A1.Flex",
    ocpus             = 4,
    memory_in_gb      = 24,
    boot_volume_in_gb = 200,
    taints            = [],
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
        source_ips  = [
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
        source_ips  = [
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
        source_ips  = [
            "0.0.0.0/0",
            "::/0"
        ]
    }
}
