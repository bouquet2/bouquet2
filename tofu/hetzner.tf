provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_firewall" "fw" {
  name   = var.cluster_name
  labels = { "type" : "talos-cluster" }
  dynamic "rule" {
    for_each = {
      for k, v in var.firewall_rules : k => v
      if v.cloud_type == "hetzner" || v.cloud_type == "both"
    }
    content {
      direction   = rule.value.direction
      protocol    = rule.value.protocol
      port        = rule.value.port
      source_ips  = rule.value.source_ips
      description = rule.value.description
    }
  }
}

resource "hcloud_server" "control_plane" {
  for_each = {
    for k, v in var.control_planes : k => v
    if v.cloud_type == "hetzner"
  }

  name         = each.value.name
  server_type  = each.value.server_type
  location     = each.value.location
  labels       = { "type" : "talos-control-plane" }
  image        = each.value.image
  user_data    = data.talos_machine_configuration.controlplane[each.key].machine_configuration
  firewall_ids = [hcloud_firewall.fw.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  depends_on = [
    data.talos_machine_configuration.controlplane
  ]
}

resource "hcloud_server" "worker" {
  for_each = {
    for k, v in var.workers : k => v
    if v.cloud_type == "hetzner"
  }

  name         = each.value.name
  server_type  = each.value.server_type
  location     = each.value.location
  labels       = { "type" : "talos-worker" }
  image        = each.value.image
  user_data    = data.talos_machine_configuration.worker[each.key].machine_configuration
  firewall_ids = [hcloud_firewall.fw.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  depends_on = [
    data.talos_machine_configuration.worker
  ]
}
