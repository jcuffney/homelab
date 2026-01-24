# GPU VM Terraform Deployment

This directory contains Terraform configuration for deploying the GPU VM on Proxmox.

## Prerequisites

1. **Terraform** installed (version >= 1.0)
2. **Proxmox API access** configured
3. **GPU PCI device ID** identified on Proxmox host

## Authentication Setup

### Option 1: Environment Variables (Recommended for CI/CD)

Set the following environment variables:

```bash
export PM_API_URL="https://proxmox.example.com:8006/api2/json"
export PM_USER="root@pam"
export PM_PASS="your-password"
```

Or use API tokens (recommended):

```bash
export PM_API_URL="https://proxmox.example.com:8006/api2/json"
export PM_API_TOKEN_ID="terraform@pve!terraform-token"
export PM_API_TOKEN_SECRET="your-token-secret"
```

### Option 2: terraform.tfvars (For Local Development)

1. Copy the example file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and fill in your Proxmox credentials and VM configuration.

**Note:** `terraform.tfvars` is gitignored to keep secrets out of version control.

### Creating Proxmox API Tokens (Recommended)

1. Log into Proxmox web interface
2. Go to **Datacenter** → **Permissions** → **API Tokens**
3. Click **Add** → **API Token**
4. Set:
   - **Token ID**: e.g., `terraform@pve!terraform-token`
   - **User**: Select a user (create one if needed, e.g., `terraform@pve`)
   - **Privilege Separation**: Enable if you want separate permissions
   - **Expiration**: Set as needed
5. Copy the **Secret** value (only shown once)
6. Grant the user appropriate permissions (VM creation, etc.)

## Finding GPU PCI Device ID

On your Proxmox host, run:

```bash
# List all PCI devices
lspci | grep -i vga

# Or get detailed info with device IDs
lspci -nn | grep -i vga

# Or for NVIDIA specifically
lspci | grep -i nvidia
```

The output will show something like:
```
01:00.0 VGA compatible controller: NVIDIA Corporation ...
```

Use `0000:01:00.0` as your `gpu_device_id` (add `0000:` prefix).

## GPU Passthrough Prerequisites

Before deploying, ensure on your Proxmox host:

1. **IOMMU is enabled** in BIOS/UEFI
2. **IOMMU is enabled** in kernel (check `/proc/cmdline` for `intel_iommu=on` or `amd_iommu=on`)
3. **GPU is isolated** from the host (blacklisted in host kernel)
4. **OVMF is installed** on Proxmox host (for UEFI support)

## Deployment

### Initialize Terraform

```bash
cd terraform
terraform init
```

### Plan Deployment

```bash
terraform plan
```

### Deploy VM

```bash
terraform apply
```

### Destroy VM

```bash
terraform destroy
```

## Verification

After deployment, SSH into the VM and verify:

1. **GPU is detected:**
   ```bash
   nvidia-smi
   ```

2. **Docker containers are running:**
   ```bash
   docker ps
   ```

3. **Ollama API is accessible:**
   ```bash
   curl http://localhost:11434/api/tags
   ```

## Troubleshooting

### VM won't start
- Check Proxmox logs: `journalctl -u pve-cluster`
- Verify GPU device ID is correct
- Ensure IOMMU is enabled

### GPU not detected in VM
- Verify GPU passthrough settings in Proxmox
- Check that NVIDIA drivers installed correctly
- Run `nvidia-smi` to verify

### Cloud-init not working
- Check cloud-init logs: `journalctl -u cloud-init`
- Verify cloud-init ISO was created correctly
