provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_dns_record" "control_planes" {
  for_each = var.control_planes
  zone_id  = var.cloudflare_zone_id
  name     = var.controlplane_url
  content  = data.tailscale_device.control_planes[each.key].addresses[0]
  comment  = each.value.name
  type     = "A"
  ttl      = 3600
}
