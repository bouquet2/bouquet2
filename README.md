<img src="https://raw.githubusercontent.com/xelab04/ServiceLogos/refs/heads/main/Kubernetes/Kubernetes%20V3.png"  height="100">

## bouquet2
Sequel to [bouquet](https://github.com/kreatoo/bouquet) that uses Talos Linux instead of k0s.


## DRAWBACKS/TODO
* When `tofu destroy` is run, it won't destroy the Tailscale entries. This is because the entry is not made by OpenTofu itself, but comes from the node. [See this issue](https://github.com/tailscale/terraform-provider-tailscale/issues/68) for more information.
* CI is not finished yet.
  * OpenTofu workflow does not have plan and apply yet.
  * K8s manifest deployment is missing entirely.
* MinIO is not yet set up (on my end).

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
    %% User Context:
    %% 1. [2025-04-10]. User knows Ansible
    %% - All nodes run Talos Linux
    %% - Will be multi-cloud
    %% - Will be expandable
    %% - hopefully be reproducible (fingers crossed)
    %% - velero might not happen depends on my wallet idk

    subgraph Core [core]
        direction TB
        core_rose["rose (control plane)"]
        core_talos_api_up["Talos API (TCP 50000*)"]:::dashed
        core_tailscale["Tailscale (siderolabs/tailscale) and KubeSpan"]
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
        storage_longhorn{"Longhorn"}:::dashed
        %% Kept Longhorn as per original chart text
        storage_s3["S3 (Oracle<br>MinIO Instance)"]
        storage_longhorn -.-> storage_s3
    end

    subgraph Ingress
        direction TB
        ingress_rr("roundrobin (cloudflare)")
        ingress_watcher["Deployment that<br>watches over<br>Ingress resources"]
        ingress_check{"Has this node failed to<br>provide resources?<br>(unstable/down)"}
        ingress_yes["yes (remove<br>DNS record<br>of node)"]
        ingress_no["no (continue<br>serving<br>connection)"]
        ingress_note(["(traefik as IngressController)"])
        style ingress_note fill:none,stroke:none,color:#aaa
        %% Make note less prominent
        ingress_rr -.-> ingress_watcher
        ingress_watcher --> ingress_check
        ingress_check -- yes --> ingress_yes
        ingress_check -- no --> ingress_no
        %% Place note loosely after decision
        ingress_yes --> ingress_note
        ingress_no --> ingress_note
    end

    subgraph InternalNetworking [Internal Networking Flow]
        direction TB
        int_net_node[Node]
        int_net_coredns[CoreDNS]
        int_net_cilium["Cilium (Both as CNI<br>and as kube-proxy<br>replacement)"]
        int_net_pod[Pod]
        %% Use dashed lines for first two hops as in the source image
        int_net_node -.-> int_net_coredns
        int_net_coredns -.-> int_net_cilium
        %% Use solid line for the last hop as in the source image
        int_net_cilium --> int_net_pod
    end

    %% Connections between subgraphs
    Storage <--> Core
    Core <--> Ingress
    %% Show that Internal Networking runs *within* the Core nodes and relates to Pods
    Core -- "runs components like" --> InternalNetworking
```
