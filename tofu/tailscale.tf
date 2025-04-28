provider "tailscale" {
  oauth_client_id     = var.tailnet_oauth_client_id
  oauth_client_secret = var.tailnet_oauth_client_secret
  tailnet             = var.tailnet
}

resource "tailscale_tailnet_key" "auth" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 3600
  description   = "Terraform generated key"
  tags = [
    "tag:k8s-operator",
    "tag:servers"
  ]
}

data "tailscale_device" "control_planes" {
  for_each = {
    for key, value in var.control_planes : key => value
  }

  hostname = each.value.name
  wait_for = "60s"

  depends_on = [
    tailscale_tailnet_key.auth,
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
    tailscale_tailnet_key.auth,
    hcloud_server.worker,
    oci_core_instance.worker
  ]
}
