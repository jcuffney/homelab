# Ubuntu Base VM

> Minimal Ubuntu VM for general purpose projects

## Overview

This is a minimal Ubuntu VM setup that can be deployed programmatically using Terraform. It provides a clean, configured Ubuntu environment with Docker, SSH access, and custom shell configuration.

## Features Included

- **jcuffney user** with sudo and docker group access
- **Docker and docker-compose** pre-installed
- **SSH key access** configured for root and jcuffney users
- **Custom bash prompt**: `user@hostname <file path> <if git directory - on branch_name>`
- **Standard dotenv files** (.bashrc, .bash_aliases, .profile) for both root and jcuffney users
  - Dotfiles are VM-specific and stored in `dotfiles/` directory

## Base OS

`Ubuntu 24 LTS`

## Deployment

This VM is deployed programmatically using Terraform for deterministic spin up/down.

### Prerequisites

1. **Terraform** installed (version >= 1.0)
2. **Proxmox API access** configured
3. **Ubuntu 24.04 cloud image** uploaded to Proxmox storage (default expects `ubuntu-24.04-server-cloudimg-amd64.img`)

### Authentication Setup

**Only authentication is required** - all other values have sensible defaults (API URL, user, VM ID, etc.).

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
- `vm_id` = `200`
- `vm_name` = `"ubuntu-vm"`
- `vm_cpu_cores` = `2`
- `vm_memory_mb` = `4096` (4 GB)
- `vm_disk_size_gb` = `50`
- `vm_storage_pool` = `"local-lvm"`
- `network_bridge` = `"vmbr0"`

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

### Cloud Image Setup

**IMPORTANT:** Cloud-init requires a cloud image (`.img` file), not a live server ISO (`.iso` file).

**How it works:** The cloud image is uploaded to Proxmox **once**, then a template is created from it **once**. When Terraform runs, it clones from the existing template in Proxmox - **no download happens**. The template is reused for all future VMs.

#### One-Time Setup: Create Cloud-Init Template

1. **Download Ubuntu 24.04 cloud image (one time):**
   - Go to: https://cloud-images.ubuntu.com/
   - Download: `ubuntu-24.04-server-cloudimg-amd64.img` (or latest 24.04 cloud image)
   - **Do not use** live server ISOs - they won't work with cloud-init

2. **Upload to Proxmox (one time):**
   - **Datacenter** → **Node** → **Storage** → **local** (or your ISO storage) → **ISO Images** → **Upload**
   - Upload the `.img` file

3. **Create Template from Cloud Image (one time):**
   
   - In Proxmox UI, create a new VM manually:
     - **Datacenter** → **Create VM**
     - Set VM ID, name (e.g., "ubuntu-24.04-template")
     - **OS**: Don't use any media (we'll attach the cloud image)
     - **System**: BIOS = SeaBIOS, Machine = Default (i440fx)
     - **Disks**: Create a small disk (will be replaced)
     - **CPU/Memory**: Minimal (1 core, 512MB is fine for template)
   - After VM creation:
     - Go to **Hardware** → **Unused Disk 0** → **Edit** → **Delete** (remove the default disk)
     - Go to **Hardware** → **Add** → **Hard Disk**
     - **Storage**: Select where you uploaded the cloud image
     - **Bus/Device**: IDE, **Device**: 0
     - **Disk size**: Match the cloud image size (or slightly larger)
     - **Format**: raw
     - Click **Add**
   - Go to **Options** → **Boot Order** → Move **IDE0** to top
   - Start the VM and let it boot once (verify it works)
   - Stop the VM
   - Right-click the VM → **Convert to Template**
   - Note the template name (e.g., "ubuntu-24.04-template")

4. **Configure Terraform to use the template:**
   
   - Edit `terraform/terraform.tfvars`
   - Uncomment and set: `vm_template = "your-template-name"`
   - Example: `vm_template = "ubuntu-24.04-template"`

#### Deploying VMs

After the template is created, each `terraform apply` will:
- Clone from the existing template in Proxmox (fast, no download)
- Apply your cloud-init configuration
- Create a new VM ready to use

The template stays in Proxmox storage and is reused for all future VMs.

### User Access

The VM is configured with two users:

- **root** - Standard root user with SSH key access
- **jcuffney** - User with root-equivalent permissions (`sudo: ALL=(ALL) NOPASSWD:ALL`) and docker group access

Both users share the same SSH public key configured in cloud-init.

### Shell Configuration

Both root and jcuffney users have custom shell configuration:

- **Custom bash prompt**: Shows `user@hostname <file path> <if git directory - on branch_name>`
- **Standard dotenv files**: `.bashrc`, `.bash_aliases`, and `.profile` are pre-configured
- **Git integration**: Prompt automatically shows current git branch when in a git repository

### Verification

After deployment, SSH into the VM and verify:

1. **VM is running:**
   ```bash
   ssh jcuffney@<vm-ip>
   # or
   ssh root@<vm-ip>
   ```

2. **Docker is installed:**
   ```bash
   docker --version
   docker-compose --version
   ```

3. **Custom prompt is working:**
   ```bash
   # Should show: user@hostname /current/path $
   # If in git repo: user@hostname /current/path on branch_name $
   ```

4. **jcuffney user has sudo access:**
   ```bash
   sudo whoami
   # Should output: root
   ```

5. **jcuffney user can use docker:**
   ```bash
   docker ps
   # Should work without sudo
   ```

### Troubleshooting

#### VM won't start
- Check Proxmox logs: `journalctl -u pve-cluster` on Proxmox host
- Verify cloud image is uploaded correctly
- Check VM configuration in Proxmox UI

#### Cloud-init not working
- Check cloud-init logs: `journalctl -u cloud-init` in VM
- Verify cloud-init ISO was created correctly in Proxmox
- Check that dotenv files were created: `ls -la ~/.bashrc ~/.bash_aliases ~/.profile`

#### SSH access not working
- Verify SSH keys are correct in cloud-init.yaml
- Check that cloud-init completed: `cloud-init status`
- Verify network connectivity to VM

#### Docker not accessible
- Verify jcuffney user is in docker group: `groups`
- May need to log out and back in for group changes to take effect
- Check Docker service is running: `sudo systemctl status docker`
