provider "oci" {
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_private_key_path
  region           = var.oci_region
}

locals {
  instance_mode = "PARAVIRTUALIZED"
  has_oci_or_oracle = length([
    for worker in values(var.workers) : worker
    if worker.cloud_type == "oci" || worker.cloud_type == "oracle"
  ]) > 0
}

data "oci_identity_availability_domains" "availability_domains" {
  count = local.has_oci_or_oracle ? 1 : 0
  #Required
  compartment_id = var.oci_tenancy_ocid
}

resource "oci_core_image" "talos_image" {
  count = local.has_oci_or_oracle ? 1 : 0

  #Required
  compartment_id = var.oci_compartment_ocid

  #Optional
  display_name = "Talos ${var.talos_version}"
  freeform_tags = {
    "TalosCluster" = var.cluster_name
  }
  launch_mode = local.instance_mode

  image_source_details {
    source_type = "objectStorageUri"
    source_uri  = var.oci_talos_image_oci_bucket_url

    #Optional
    operating_system         = "Talos Linux"
    operating_system_version = var.talos_version
    source_image_type        = "QCOW2"
  }
}

resource "oci_core_shape_management" "image_shape" {
  for_each = {
    for k, v in var.workers : k => v
    if v.cloud_type == "oci" || v.cloud_type == "oracle"
  }
  # Required
  compartment_id = var.oci_compartment_ocid
  image_id       = oci_core_image.talos_image[0].id
  shape_name     = each.value.server_type
}

resource "oci_core_instance" "worker" {
  for_each = {
    for k, v in var.workers : k => v
    if v.cloud_type == "oci" || v.cloud_type == "oracle"
  }

  compartment_id = var.oci_compartment_ocid
  shape          = each.value.server_type

  metadata = {
    user_data = base64encode(data.talos_machine_configuration.worker[each.key].machine_configuration)
  }

  shape_config {
    ocpus         = each.value.ocpus
    memory_in_gbs = each.value.memory_in_gb
  }

  display_name        = each.value.name
  availability_domain = data.oci_identity_availability_domains.availability_domains[0].availability_domains[each.key % length(data.oci_identity_availability_domains.availability_domains[0].availability_domains)].name

  create_vnic_details {
    assign_public_ip = true
    assign_ipv6ip    = true
  }

  agent_config {
    is_monitoring_disabled   = true
    are_all_plugins_disabled = true
    is_management_disabled   = true
  }

  availability_config {
    is_live_migration_preferred = true
    recovery_action             = "RESTORE_INSTANCE"
  }

  source_details {
    source_type             = "image"
    source_id               = oci_core_image.talos_image[0].id
    boot_volume_size_in_gbs = each.value.boot_volume_in_gb
  }
  preserve_boot_volume = false

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      metadata.user_data,
      defined_tags
    ]
  }

  launch_options {
    boot_volume_type        = local.instance_mode
    network_type            = local.instance_mode
    remote_data_volume_type = local.instance_mode
    firmware                = "UEFI_64"
  }

  depends_on = [
    data.tailscale_device.control_planes
  ]
}
