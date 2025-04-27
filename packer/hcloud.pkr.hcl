# hcloud.pkr.hcl

packer {
  required_plugins {
    hcloud = {
      source  = "github.com/hetznercloud/hcloud"
      version = "~> 1"
    }
  }
}

variable "talos_version" {
  type    = string
  default = "v1.9.2"
}

variable "arch" {
  type    = string
  default = "arm64"
}

variable "server_type" {
  type    = string
  default = "cax11"
}

variable "server_location" {
  type    = string
}

variable "hcloud_token" {
  type    = string
}

locals {
  # Schematic
  # ---
  # customization:
  #  systemExtensions:
  #      officialExtensions:
  #          - siderolabs/qemu-guest-agent
  #          - siderolabs/tailscale
  image = "https://factory.talos.dev/image/7d4c31cbd96db9f90c874990697c523482b2bae27fb4631d5583dcd9c281b1ff/${var.talos_version}/hcloud-${var.arch}.raw.xz"
}

source "hcloud" "talos" {
  rescue       = "linux64"
  image        = "debian-12"
  location     = "${var.server_location}"
  server_type  = "${var.server_type}"
  ssh_username = "root"
  token       = "${var.hcloud_token}"

  snapshot_name   = "talos system disk - ${var.arch} - ${var.talos_version}"
  snapshot_labels = {
    type    = "infra",
    os      = "talos",
    version = "${var.talos_version}",
    arch    = "${var.arch}",
  }
}

build {
  sources = ["source.hcloud.talos"]

  provisioner "shell" {
    inline = [
      "apt-get install -y wget",
      "wget -O /tmp/talos.raw.xz ${local.image}",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",
    ]
  }
}

