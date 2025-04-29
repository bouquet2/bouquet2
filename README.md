<img src="https://raw.githubusercontent.com/xelab04/ServiceLogos/refs/heads/main/Kubernetes/Kubernetes%20V3.png"  height="100">

## bouquet2
Sequel to [bouquet](https://github.com/kreatoo/bouquet) that uses Talos Linux instead of k0s.

> [!WARNING]
> This is a work in progress and is not deployed yet.

## DRAWBACKS/TODO
* When `tofu destroy` is run, it won't destroy the Tailscale entries. This is because the entry is not made by OpenTofu itself, but comes from the node. [See this issue](https://github.com/tailscale/terraform-provider-tailscale/issues/68) for more information.
* OCI part does not support multi-arch. As it is not needed for this project, I will not add it.
* OCI part does not support being added as a control plane node. As it is not needed for this project, I will not add it. Recommend using Hetzner Cloud or another provider that is easier to handle.
  * The OCI part is mainly to use the Always Free Tier which is why these parts are not added. I don't trust it enough to use it as a control plane node. If that changes, I will add it.
* Worker internal roundrobin load-balancing does not support automatic failover.
  * I will add a Deployment that watches over the Ingress resources and removes the DNS record of the node if it is down.
  * Control plane node uses KubePrism so that won't be an issue.

## Setup

### Prerequisites
* [OpenTofu](https://opentofu.org)
* [Kubectl](https://kubernetes.io/docs/tasks/tools/)
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

### Destroying the cluster
just destroy
```


### Servers

* iris
    * Cloud: Hetzner Cloud 
    * Region: Nuremberg
    * OS: Talos Linux
    * Role: Agent node
    * Machine: CAX11 (Ampere Altra) with 2 cores, 4GB RAM, 40GB storage

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
%%{init: {'theme': 'dark', 'themeVariables': {'mainBkg': '#282a36', 'nodeBorder': '#f8f8f2', 'textColor': '#f8f8f2', 'lineColor': '#f8f8f2', 'primaryColor': '#282a36', 'primaryTextColor': '#f8f8f2', 'primaryBorderColor': '#f8f8f2'}}}%%
graph LR
    classDef dashed stroke-dasharray: 5 5, stroke-width:1px

    %% - All nodes run Talos Linux
    %% - Will be multi-cloud
    %% - Will be expandable
    %% - hopefully be reproducible (fingers crossed)
    %% - velero might not happen depends on my wallet idk

    subgraph Core [core]
        direction TB
        core_rose["rose (control plane)"]
        core_talos_api_up["Talos API (TCP 50000*)"]:::dashed
        core_tailscale["Tailscale (siderolabs/tailscale)"]
        core_talos_api_down["Talos API (TCP 50000*)"]:::dashed
        core_iris["iris (worker)"]
        core_lily["lily (worker)"]

        core_iris --> core_talos_api_down
        core_lily --> core_talos_api_down
        core_talos_api_down --> core_tailscale
        core_tailscale --> core_talos_api_up
        core_talos_api_up --> core_rose
    end

    subgraph Storage [storage]
        direction TB
        storage_openebs{"Longhorn"}:::dashed
        storage_velero["backup (velero)"]:::dashed
        storage_s3["S3 (Hetzner<br>Object Storage)"]

        storage_openebs -.-> storage_velero
        storage_velero -.-> storage_s3
    end

    subgraph Ingress
        direction TB
        ingress_rr("roundrobin (cloudflare)")
        ingress_watcher["Deployment that<br>watches over<br>Ingress resources"]
        ingress_check{"Has this node failed to<br>provide resources?<br>(unstable/down)"}
        ingress_yes["yes (remove<br>DNS record<br>of node)"]
        ingress_no["no (continue<br>serving<br>connection)"]
        ingress_note(["(traefik as IngressController)"])
        style ingress_note fill:none,stroke:none,color:#aaa %% Make note less prominent

        ingress_rr -.-> ingress_watcher
        ingress_watcher --> ingress_check
        ingress_check -- yes --> ingress_yes
        ingress_check -- no --> ingress_no
        %% Place note loosely after decision
        ingress_yes --> ingress_note
        ingress_no --> ingress_note
    end

    %% Connections between subgraphs
    Storage <--> Core
    Core <--> Ingress
```
