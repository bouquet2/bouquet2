# OpenTofu Infrastructure

This directory contains Terraform configurations for deploying and managing bouquet2. The infrastructure is built using Talos Linux on Hetzner Cloud, with Cloudflare DNS management and Tailscale networking integration.

## Infrastructure Components

- **Kubernetes Cluster**: Managed by Talos Linux
- **Cloud Provider**: Hetzner Cloud
- **DNS Management**: Cloudflare
- **Networking**: Tailscale for management networking, Kubespan for in-cluster networking

## Configuration Files

- `versions.tf`: Provider and version constraints
- `variables.tf`: Input variables definition
- `nodes.tfvars`: Node configuration (control planes and workers)
- `secrets.tfvars`: Sensitive configuration (create from `secrets.tfvars.example`)
- `talos.tf`: Talos-specific configurations
- `tailscale.tf`: Tailscale integration
- `cloudflare.tf`: Cloudflare DNS management
- `hetzner.tf`: Hetzner Cloud resources

## Network Configuration

### URLs
- Control Plane: controlplane.internal.krea.to
- Worker Nodes: *.internal.krea.to
- External Access: *.krea.to
- Load Balancer: lb.krea.to (external), lb.internal.krea.to (internal)

### Firewall Rules
- HTTPS (TCP/UDP): Port 443
- Tailscale: Port 41641/UDP
- KubeSpan: Port 51820/UDP

## Maintenance

- State files are stored locally in `terraform.tfstate`
- Backup state files are automatically created with timestamps
- Use `tofu state` commands to inspect and manage resources