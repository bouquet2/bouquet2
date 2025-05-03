resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "controlplane" {
  for_each = {
    for k, v in var.control_planes : k => v
  }

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.controlplane_url}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches = [
    templatefile("${path.module}/templates/tailscale-config.yaml.tmpl", {
      TS_AUTHKEY  = var.tailscale_auth_key,
      TS_HOSTNAME = each.value.name
    }),
    templatefile("${path.module}/templates/kubeprism-enable.yaml.tmpl", {}),
    templatefile("${path.module}/templates/longhorn.yaml.tmpl", {}),
    templatefile("${path.module}/templates/disable-cni.yaml.tmpl", {}),
    templatefile("${path.module}/templates/cilium.yaml.tmpl", {}),
    templatefile("${path.module}/templates/kubespan-enable.yaml.tmpl", {})
  ]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration

  endpoints = flatten([
    [for cp in data.tailscale_device.control_planes : cp.addresses],
  ])

  nodes = flatten([
    [for cp in data.tailscale_device.control_planes : cp.addresses[0]],
    [for worker in data.tailscale_device.workers : worker.addresses[0]],
  ])
}

resource "talos_machine_bootstrap" "bootstrap" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = data.tailscale_device.control_planes["1"].addresses[0]
}

data "talos_machine_configuration" "worker" {
  for_each = {
    for k, v in var.workers : k => v
  }

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.controlplane_url}:6443"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches = [
    templatefile("${path.module}/templates/tailscale-config.yaml.tmpl", {
      TS_AUTHKEY  = var.tailscale_auth_key,
      TS_HOSTNAME = each.value.name
    }),
    templatefile("${path.module}/templates/kubeprism-enable.yaml.tmpl", {}),
    templatefile("${path.module}/templates/longhorn.yaml.tmpl", {}),
    templatefile("${path.module}/templates/disable-cni.yaml.tmpl", {}),
    templatefile("${path.module}/templates/cilium.yaml.tmpl", {}),
    templatefile("${path.module}/templates/kubespan-enable.yaml.tmpl", {})
  ]

  depends_on = [
    talos_machine_bootstrap.bootstrap,
    cloudflare_dns_record.control_planes
  ]
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = data.tailscale_device.control_planes["1"].addresses[0]
  depends_on = [
    cloudflare_dns_record.control_planes,
    talos_machine_bootstrap.bootstrap
  ]
}
