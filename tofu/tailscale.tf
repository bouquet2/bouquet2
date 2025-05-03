provider "tailscale" {
  oauth_client_id     = var.tailnet_oauth_client_id
  oauth_client_secret = var.tailnet_oauth_client_secret
  tailnet             = var.tailnet
}

data "tailscale_device" "control_planes" {
  for_each = {
    for key, value in var.control_planes : key => value
  }

  hostname = each.value.name
  wait_for = "60s"

  depends_on = [
    hcloud_server.control_plane
  ]
}

data "tailscale_device" "workers" {
  for_each = {
    for key, value in var.workers : key => value
  }

  hostname = each.value.name
  wait_for = "60s"

  depends_on = [
    hcloud_server.worker
  ]
}
