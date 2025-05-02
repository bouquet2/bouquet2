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

resource "cloudflare_dns_record" "workers_internal" {
  for_each = var.workers
  zone_id  = var.cloudflare_zone_id
  name     = "${each.value.name}.${var.worker_url_internal_base}"
  content  = data.tailscale_device.workers[each.key].addresses[0]
  comment  = each.value.name
  type     = "A"
  ttl      = 3600
}

resource "cloudflare_dns_record" "hetzner_workers_rr_external" {
  for_each = {
    for k, v in var.workers : k => v if v.cloud_type == "hetzner"
  }
  zone_id = var.cloudflare_zone_id
  name    = var.rr_url
  content = hcloud_server.worker[each.key].ipv4_address
  comment = each.value.name
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "hetzner_workers_external" {
  for_each = {
    for k, v in var.workers : k => v if v.cloud_type == "hetzner"
  }
  zone_id = var.cloudflare_zone_id
  name    = "${each.value.name}.${var.worker_url_external_base}"
  content = hcloud_server.worker[each.key].ipv4_address
  comment = each.value.name
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "workers_rr_internal" {
  for_each = {
    for k, v in var.workers : k => v
  }
  zone_id = var.cloudflare_zone_id
  name    = var.rr_internal_url
  content  = data.tailscale_device.workers[each.key].addresses[0]
  comment = each.value.name
  type    = "A"
  ttl     = 1
}

resource "cloudflare_dns_record" "wildcard_rr_external" {
  zone_id = var.cloudflare_zone_id
  name    = "*"
  content = var.rr_url
  comment = "Wildcard RR External"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "wildcard_rr_internal" {
  zone_id = var.cloudflare_zone_id
  name    = "*.internal"
  content = var.rr_internal_url
  comment = "Wildcard RR Internal"
  type    = "CNAME"
  ttl     = 1
}

