# Kubernetes Infrastructure

This directory contains the complete Kubernetes infrastructure configuration for the krea.to platform. The infrastructure is organized into two main categories: core components and applications.

## Deployment Order

The infrastructure should be deployed in the following order:

1. Core components (from `core/` directory)

2. Applications (from `apps/` directory):
   - Applications can be deployed after core components are ready
   - Some applications may have dependencies on specific core components

## Deployment

To deploy the entire infrastructure:

```bash
just deploy-manifests
```

To deploy individual parts of the infrastructure, please refer to the README files in `core/` and `apps/` subdirectories.

## Infrastructure Overview

The infrastructure is built on a foundation of core components that provide essential services like ingress routing, certificate management, storage, and databases. Applications are deployed on top of this infrastructure, leveraging these core services.

For detailed information about specific components and applications, please refer to their respective README files in the `core/` and `apps/` directories.

## Security

- All components use appropriate security contexts
- Network policies are implemented for security
- TLS certificates are managed by cert-manager
- Cloudflare integration for DDoS protection
- Internal services are isolated using network policies

## Maintenance

- Regular backups are configured for critical components
- High availability is implemented where appropriate
- Resource limits and requests are configured
- Monitoring and alerting are in place 