<img src="https://raw.githubusercontent.com/xelab04/ServiceLogos/refs/heads/main/Kubernetes/Kubernetes%20V3.png"  height="100">

## bouquet2: Talos boogaloo
Sequel to [bouquet](https://github.com/kreatoo/bouquet) that uses Talos Linux instead of k0s.

> [!WARNING]
> This is a work in progress and is not deployed yet.

## Setup

### Servers

* tulip
    * Cloud: OCI (Oracle Cloud Infrastructure)
    * Region: Frankfurt
    * OS: Talos Linux
    * Role: Agent node
    * Machine: VM.Standard.A1.Flex (Ampere Altra) with 4 cores, 24GB RAM, 200GB storage

* rose
    * Cloud: Hetzner Cloud
    * Region: Helsinki
    * OS: Talos Linux
    * Role: Control plane node
    * Machine: CAX11 (Ampere Altra) with 2 cores, 4GB RAM, 40GB storage
 
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
        core_tulip["tulip (worker)"]
        core_lily["lily (worker)"]

        core_tulip --> core_talos_api_down
        core_lily --> core_talos_api_down
        core_talos_api_down --> core_tailscale
        core_tailscale --> core_talos_api_up
        core_talos_api_up --> core_rose
    end

    subgraph Storage [storage]
        direction TB
        storage_openebs{"OpenEBS"}:::dashed
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
