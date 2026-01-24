# GPU VM

> Since the GPU can only be assigned to 1 VM - this VM is a shared piece of infrastructure to support the homelab.

## GPU Workloads / Services

- [x] Ollama (GPU for running Models) - Exposes API on port 11434
- [x] Plex (GPU for Media Transcoding) - Exposes web UI on port 32400

## Base OS 

`Ubuntu 24 LTS`

## Deployment

This VM is deployed programmatically using Terraform for deterministic spin up/down.

### Prerequisites

1. **Terraform** installed (version >= 1.0)
2. **Proxmox API access** configured
3. **GPU PCI device ID** identified on Proxmox host
4. **Proxmox host requirements:**
   - IOMMU enabled in BIOS/UEFI
   - IOMMU enabled in kernel (`intel_iommu=on` or `amd_iommu=on`)
   - GPU isolated from host
   - OVMF installed for UEFI support

### Authentication Setup

#### Option 1: Environment Variables (Recommended for CI/CD)

Set the following environment variables:

```bash
export PM_API_URL="https://proxmox.example.com:8006/api2/json"
export PM_USER="root@pam"
export PM_PASS="your-password"
```

Or use API tokens (recommended for security):

```bash
export PM_API_URL="https://proxmox.example.com:8006/api2/json"
export PM_API_TOKEN_ID="terraform@pve!terraform-token"
export PM_API_TOKEN_SECRET="your-token-secret"
```

#### Option 2: terraform.tfvars (For Local Development)

1. Copy the example file:
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and fill in your Proxmox credentials and VM configuration.

**Note:** `terraform.tfvars` is gitignored to keep secrets out of version control.

### Creating Proxmox API Tokens

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

### Finding GPU PCI Device ID

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

Use `0000:01:00.0` as your `gpu_device_id` in `terraform.tfvars` (add `0000:` prefix).

### Spin Up VM

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Spin Down VM

```bash
cd terraform
terraform destroy
```

### Verification

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

4. **Plex web UI is accessible:**
   ```bash
   curl http://localhost:32400/web
   ```

### Configuration

All VM specifications are configurable via variables in `terraform/terraform.tfvars`:

- `vm_cpu_cores` - Number of CPU cores (default: 4)
- `vm_memory_mb` - RAM in MB (default: 8192)
- `vm_disk_size_gb` - Disk size in GB (default: 100)
- `gpu_device_id` - PCI device ID for GPU passthrough
- `gpu_rombar` - ROM bar setting (0 or 1, default 0)
- `gpu_x_vga` - Enable X-VGA (0 or 1, default 1)
- `network_bridge` - Network bridge name (default: vmbr0)
- `vm_storage_pool` - Storage pool for VM disk (default: local-lvm)
- `vm_iso_storage_pool` - Storage pool for cloud-init ISO (default: local)

See `terraform/terraform.tfvars.example` for all available options.

### User Access

The VM is configured with two users:

- **root** - Standard root user with SSH key access
- **jcuffney** - User with root-equivalent permissions (`sudo: ALL=(ALL) NOPASSWD:ALL`)

Both users share the same SSH public key configured in cloud-init.

### Troubleshooting

#### VM won't start
- Check Proxmox logs: `journalctl -u pve-cluster` on Proxmox host
- Verify GPU device ID is correct
- Ensure IOMMU is enabled on Proxmox host

#### GPU not detected in VM
- Verify GPU passthrough settings in Proxmox
- Check that NVIDIA drivers installed correctly (may require reboot)
- Run `nvidia-smi` to verify
- Check `/dev/nvidia*` devices exist

#### Cloud-init not working
- Check cloud-init logs: `journalctl -u cloud-init` in VM
- Verify cloud-init ISO was created correctly in Proxmox
- Check that docker-compose.yml was copied to `/srv/docker/docker-compose.yml`

#### Containers not starting
- Check Docker logs: `docker logs ollama` or `docker logs plex`
- Verify GPU devices are accessible: `ls -la /dev/nvidia*`
- Check Docker daemon is using NVIDIA runtime: `docker info | grep nvidia`