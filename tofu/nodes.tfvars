cluster_name = "bouquet2"
controlplane_url = "controlplane.internal.kreato.dev"

control_planes = {
    1 = {
        name = "rose-new"
        cloud_type = "hetzner",
        server_type = "cax21",
        location = "hel1",
        image = "233648394",
        taints = [],
    }
}

workers = {
    1 = {
        name = "lily-new"
        cloud_type = "hetzner",
        server_type = "cax21",
        location = "fsn1",
        image = "233648394",
        taints = [],
    },
    2 = {
        name = "tulip-new"
        cloud_type = "oci",
        server_type = "VM.Standard.A1.Flex",
        ocpus = 4,
        memory_in_gb = 24,
        boot_volume_in_gb = 200,
        taints = [],
    }
}
