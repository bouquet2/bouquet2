# Core Infrastructure

This directory contains Kubernetes manifests for core infrastructure components that provide essential services to the cluster. These components are deployed using Kustomize and Helm charts where appropriate.

## Components Overview

### [moniquet](https://github.com/kreatoo/moniquet)
- **Purpose**: Cluster management and monitoring
- **Namespace**: `moniquet`
- **Features**:
    - Discord webhook for notifications
    - Multiple replicas for high availability

### [Traefik](https://github.com/traefik/traefik)
- **Purpose**: Edge router and load balancer
- **Namespace**: `traefik`
- **Features**:
  - HTTP/3 support
  - Cloudflare integration with IP allowlist
  - Cross-namespace routing enabled
  - Default ingress class
  - 2 replicas for high availability
  - Host port 443 for HTTPS

### [cert-manager](https://github.com/cert-manager/cert-manager)
- **Purpose**: Certificate management
- **Namespace**: `traefik`
- **Features**:
  - Automatic SSL/TLS certificate management
  - Let's Encrypt integration
  - Cloudflare DNS01 challenge support
  - Wildcard certificates for:
    - `*.krea.to`
    - `*.internal.krea.to`
    - `*.kreato.dev`
    - `*.internal.kreato.dev`

### [Longhorn](https://github.com/longhorn/longhorn)
- **Purpose**: Distributed block storage
- **Namespace**: `longhorn-system`
- **Features**:
  - Distributed block storage
  - S3 backup support
  - Web UI accessible at `longhorn.internal.krea.to`
  - Network policies for security
  - Privileged security context

### [CloudNativePG](https://github.com/cloudnative-pg/cloudnative-pg)
- **Purpose**: PostgreSQL operator
- **Namespace**: `cnpg-system`
- **Features**:
  - Kubernetes-native PostgreSQL
  - High availability
  - Automated backups
  - Point-in-time recovery

### [Dragonfly](https://github.com/dragonflydb/dragonfly)
- **Purpose**: In-memory data store
- **Namespace**: `dragonfly-operator-system`
- **Features**:
  - Redis-compatible
  - High performance
  - Memory efficient
  - Privileged security context

### [Cilium](https://github.com/cilium/cilium)
- **Purpose**: Container networking and security
- **Namespace**: `kube-system`
- **Features**:
  - Kubernetes-native networking
  - eBPF-based networking and security
  - kube-proxy replacement
  - Kubernetes IPAM integration
  - Enhanced security capabilities
  - Network policy enforcement

## Directory Structure

Each component follows a similar structure:
```
component-name/
├── namespace.yaml
├── kustomization.yaml
├── values.yaml (if using Helm)
└── other component-specific manifests
```

## Deployment

Components are deployed using Kustomize. The main `kustomization.yaml` in this directory includes all components. To deploy:

```bash
kubectl apply -k .
```

To deploy a specific component:

```bash
kubectl apply -k ./component-name/
```

For components that use Helm charts, you'll need to enable Helm support:

```bash
kubectl kustomize --enable-helm | kubectl apply -f -
```

## Notes

- All components use appropriate security contexts and network policies
- Core components are deployed in their own namespaces
- Some components require privileged security context
- Components are configured with appropriate resource limits and requests
- Infrastructure components are deployed before applications 
