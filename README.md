<img src="https://raw.githubusercontent.com/xelab04/ServiceLogos/refs/heads/main/Kubernetes/Kubernetes%20V3.png"  height="100">

## bouquet2
![Uptime](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fbouquet2%2Fstatus.krea.to%2Fmaster%2Fapi%2Flb%2Fuptime-day.json)
![Uptime](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fbouquet2%2Fstatus.krea.to%2Fmaster%2Fapi%2Flb%2Fuptime-week.json)
![Uptime](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fbouquet2%2Fstatus.krea.to%2Fmaster%2Fapi%2Flb%2Fuptime-month.json)
![Uptime](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fbouquet2%2Fstatus.krea.to%2Fmaster%2Fapi%2Flb%2Fuptime-year.json)

Infinitely scalable, multi-cloud, secure and network-agnostic declarative Kubernetes configuration that focuses on stability and simplicity, while not compromising on modularity.

Sequel to [bouquet](https://github.com/kreatoo/bouquet) that uses Talos Linux instead of k0s, OpenTofu for provisioning resources and many more improvements.

## DRAWBACKS/TODO
* When `tofu destroy` is run, it won't destroy the Tailscale entries. This is because the entry is not made by OpenTofu itself, but comes from the node. [See this issue](https://github.com/tailscale/terraform-provider-tailscale/issues/68) for more information.

## Setup

### Prerequisites
* [OpenTofu](https://opentofu.org)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [talosctl](https://www.talos.dev/v1.9/introduction/quickstart/#talosctl)
* [just](https://github.com/casey/just)
* [Packer](https://www.packer.io/)

#### Installation
```bash
### Generating the image (Hetzner Cloud)
cd packer
cp secrets.hcl.example secrets.hcl

# Edit secrets.hcl and add your secrets
vim secrets.hcl

# Build the image
cd ..
just hcloud-image-build

### Deploying the cluster
cd tofu
mv secrets.tfvars.example secrets.tfvars

# Edit secrets.tfvars and add your secrets
vim secrets.tfvars

# Configure nodes (make sure to replace the Image IDs and URLs with the correct ones)
vim nodes.tfvars

cd ..

just deploy

### Deploying Kubernetes manifests
just deploy-manifests

### Do this after Cilium is up
just delete-ciliumjob

### Destroying the cluster
just destroy
```

### Kubernetes Manifests

The Kubernetes manifests are organized in the `manifests/` directory and contain all the infrastructure components and applications. For detailed information about those, please refer to the [manifests documentation](manifests/README.md).

### Servers

* iris
    * Cloud: Hetzner Cloud 
    * Region: Nuremberg
    * OS: Talos Linux
    * Role: Agent node
    * Machine: CAX21 (Ampere Altra) with 4 cores, 8GB RAM, 80GB storage

* rose
    * Cloud: Hetzner Cloud
    * Region: Helsinki
    * OS: Talos Linux
    * Role: Control plane node
    * Machine: CAX21 (Ampere Altra) with 4 cores, 8GB RAM, 80GB storage
 
* lily
    * Cloud: Hetzner Cloud
    * Region: Falkenstein
    * OS: Talos Linux
    * Role: Agent node
    * Machine: CAX21 (Ampere Altra) with 4 cores, 8GB RAM, 80GB storage

### System Architecture Overview
```mermaid
graph LR
    classDef dashed stroke-dasharray: 5 5, stroke-width:1px

    subgraph Core [core]
        direction TB
        core_rose["rose (control plane)"]
        core_talos_api_up["Talos API (TCP 50000*)"]:::dashed
        core_cilium_wireguard["Cilium WireGuard (internal mesh) (UDP 51871)"]
        core_talos_api_down["Talos API (TCP 50000*)"]:::dashed
        core_iris["iris (worker)"]
        core_lily["lily (worker)"]
        core_iris <--> core_talos_api_down
        core_lily <--> core_talos_api_down
        core_talos_api_down <--> core_cilium_wireguard
        core_cilium_wireguard <--> core_talos_api_up
        core_talos_api_up <--> core_rose
    end

    subgraph Access [access]
        direction TB
        ext_tailscale["Tailscale (siderolabs/tailscale)<br>External access and fallback (UDP 41641)"]
    end

    subgraph Storage [storage]
        direction TB
        storage_longhorn{"Longhorn"}:::dashed
        %% Kept Longhorn as per original chart text
        storage_s3["Backups (S3) (Oracle<br>MinIO Instance)"]
        storage_longhorn -.-> storage_s3
    end

    %% Connections between subgraphs
    Storage <--> Core
    Access <--> Core
```
