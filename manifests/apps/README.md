# Applications

This directory contains Kubernetes manifests for various applications deployed in the cluster. Each application is managed using Kustomize and may include Helm charts where appropriate.

## Applications Overview

### [LiteLLM](https://github.com/berriai/litellm)
- **Purpose**: LLM proxy
- **Namespace**: `litellm`
- **URL**: [api.ai.krea.to](https://api.ai.krea.to)
- **Components**:
    - Web service (port 4000)
    - PostgreSQL database
    - Persistent storage (5Gi)

### [Mastodon](https://github.com/mastodon/mastodon)
- **Purpose**: Social media platform
- **Namespace**: `mastodon`
- **URL**: [m.kreato.dev](https://m.kreato.dev)
- **Components**:
  - Web service (port 3000)
  - Streaming service
  - Sidekiq workers
  - PostgreSQL database
  - Dragonfly for Redis
  - Persistent storage (10Gi)

### [Jellyfin](https://github.com/jellyfin/jellyfin)
- **Purpose**: Media server
- **Namespace**: `jellyfin`
- **URL**: [media.krea.to](https://media.krea.to)
- **Features**:
  - Media streaming platform
  - Persistent storage:
    - Config: 5Gi
    - Media: 10Gi

### [MinIO](https://github.com/minio/minio)
- **Purpose**: Object storage
- **Namespace**: `minio`
- **URLs**:
  - [s3.krea.to](https://s3.krea.to)
  - [bin.kreato.dev](https://bin.kreato.dev)
- **Components**:
  - S3-compatible storage
  - Ingress configuration
  - Service endpoints

### [n8n](https://github.com/n8n-io/n8n)
- **Purpose**: Workflow automation
- **Namespace**: `n8n`
- **URL**: [n8n.krea.to](https://n8n.krea.to)
- **Features**:
  - Workflow automation platform
  - Node-based automation

### [Umami](https://github.com/umami-software/umami)
- **Purpose**: Analytics platform
- **Namespace**: `umami`
- **URL**: [umami.krea.to](https://umami.krea.to)
- **Components**:
  - Web interface (port 3000)
  - PostgreSQL database

### [Koito](https://github.com/gabehf/koito)
- **Purpose**: Music scrobbling service
- **Namespace**: `koito`
- **URL**: [fm.krea.to](https://fm.krea.to)
- **Components**:
  - Web service (port 4110)
  - PostgreSQL database
  - Persistent storage

## Directory Structure

Each application follows a similar structure:
```
app-name/
├── namespace.yaml
├── kustomization.yaml
├── values.yaml (if using Helm)
├── gateway.yaml
├── networkpolicy.yaml
└── other application-specific manifests
```

## Deployment

Applications are deployed using Kustomize. The main `kustomization.yaml` in this directory includes all applications. To deploy:

```bash
kubectl apply -k .
```

To deploy a specific application:

```bash
kubectl apply -k ./app-name/
```

For applications that use Helm charts, you'll need to enable Helm support. You can do this in two ways:

1. Standard deployment with Helm support:
```bash
kubectl kustomize --enable-helm | kubectl apply -f -
```

2. Server-side apply with force conflicts (useful for applications with large ConfigMaps):
```bash
kubectl kustomize --enable-helm | kubectl apply --server-side --force-conflicts -f -
```

Note: Server-side apply command is particularly recommended as it is the default for the justfile and the CI. It may not work otherwise.

## Notes

- All applications use Traefik for ingress routing
- TLS certificates are managed by cert-manager
- Network policies are implemented for security
- Persistent storage is used where needed
- Applications are configured with appropriate resource limits and requests 
