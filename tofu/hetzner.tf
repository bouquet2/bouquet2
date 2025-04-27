provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "control_plane" {
  for_each = {
    for k, v in var.control_planes : k => v
    if v.cloud_type == "hetzner"
  }

  name        = each.value.name
  server_type = each.value.server_type
  location    = each.value.location
  labels      = { "type" : "talos-control-plane" }
  image       = each.value.image
  user_data   = data.talos_machine_configuration.controlplane[each.key].machine_configuration

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
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

  name        = each.value.name
  server_type = each.value.server_type
  location    = each.value.location
  labels      = { "type" : "talos-worker" }
  image       = each.value.image
  user_data   = data.talos_machine_configuration.worker[each.key].machine_configuration

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  depends_on = [
    data.talos_machine_configuration.worker
  ]
}
