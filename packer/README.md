# Packer Images

This directory contains Packer configurations for building custom Talos Linux images for Hetzner Cloud.

## Configuration Files

- `hcloud.pkr.hcl`: Main Packer configuration for building Talos images
- `secrets.hcl.example`: Example secrets file (copy to `secrets.hcl` and add your Hetzner Cloud token)
- `schematic.yaml`: Schematic configuration for Talos Linux

## Building Images

1. Copy and configure secrets:
   ```bash
   cp secrets.hcl.example secrets.hcl
   # Edit secrets.hcl with your Hetzner Cloud token
   ```

2. Build the image:
   ```bash
   cd ..
   just hcloud-image-build
   ```