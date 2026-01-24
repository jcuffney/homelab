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
3. **Ubuntu 24.04 cloud image** uploaded to Proxmox storage (default expects `ubuntu-24.04-server-cloudimg-amd64.img`)
4. **Proxmox host requirements:**
   - IOMMU enabled in BIOS/UEFI
   - IOMMU enabled in kernel (`intel_iommu=on` or `amd_iommu=on`)
   - GPU isolated from host
   - OVMF installed for UEFI support

### Authentication Setup

**Only authentication is required** - all other values have sensible defaults (API URL, user, VM ID, GPU device ID, etc.).

#### Option 1: terraform.tfvars (Recommended for Local Development)

1. Copy the example file:
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and uncomment **only** the authentication method you want to use:

   **Password authentication:**
   ```hcl
   proxmox_password = "your-password-here"
   ```
   Uses defaults: `proxmox_api_url = "https://192.168.1.10:8006/api2/json"`, `proxmox_user = "root@pam"`

   **OR Token authentication (recommended):**
   ```hcl
   proxmox_token_id     = "root@pam!terraform-token"
   proxmox_token_secret = "your-token-secret-here"
   ```
   Uses default: `proxmox_api_url = "https://192.168.1.10:8006/api2/json"`

**Note:** `terraform.tfvars` is gitignored to keep secrets out of version control.

#### Option 2: Environment Variables (For CI/CD)

Set environment variables (note: provider uses `PM_*` as fallback, so use `terraform.tfvars` for `PROXMOX_*` variables):

```bash
export PM_PASS="your-password"
# OR
export PM_API_TOKEN_ID="root@pam!terraform-token"
export PM_API_TOKEN_SECRET="your-token-secret"
```

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

### Default Values

The following values have sensible defaults and don't need to be configured:

- `proxmox_api_url` = `"https://192.168.1.10:8006/api2/json"`
- `proxmox_user` = `"root@pam"`
- `proxmox_target_node` = `"numenor"`
- `vm_id` = `100`
- `vm_name` = `"rivendell"`
- `vm_cpu_cores` = `12`
- `vm_memory_mb` = `32768` (32 GB)
- `vm_disk_size_gb` = `750`
- `vm_storage_pool` = `"local-lvm"`
- `vm_iso_storage_pool` = `"local"`
- `gpu_device_id` = `"0000:3b:00.0"` (defaults to user's GPU)
- `gpu_rombar` = `0`
- `gpu_x_vga` = `1`
- `network_bridge` = `"vmbr0"`
- `vm_cloud_image` = `"ubuntu-24.04-server-cloudimg-amd64.img"`

**To override any default**, set the variable in `terraform.tfvars` or use `-var` flags with `terraform apply`.

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

### Cloud Image Setup

**IMPORTANT:** Cloud-init requires a cloud image (`.img` file), not a live server ISO (`.iso` file).

Before deploying, ensure you have an Ubuntu 24.04 **cloud image** uploaded to Proxmox storage:

1. **Download Ubuntu 24.04 cloud image:**
   - Go to: https://cloud-images.ubuntu.com/
   - Download: `ubuntu-24.04-server-cloudimg-amd64.img` (or latest 24.04 cloud image)
   - **Do not use** live server ISOs - they won't work with cloud-init

2. **Upload to Proxmox:**
   - **Datacenter** → **Node** → **Storage** → **local** (or your ISO storage) → **ISO Images** → **Upload**
   - Upload the `.img` file

3. **Verify filename:**
   - The default expects: `ubuntu-24.04-server-cloudimg-amd64.img`
   - If your image has a different name, set `vm_cloud_image` in `terraform.tfvars`

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