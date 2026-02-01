terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }

  # Remote backend configuration
  # Choose ONE of the following options:

  # Option 1: Terraform Cloud (Recommended - Free tier available)
  # 1. Sign up at https://app.terraform.io
  # 2. Create a workspace (CLI-driven workflow)
  # 3. Get your organization name and workspace name
  # 4. Uncomment and configure:
  # backend "remote" {
  #   organization = "your-org-name"
  #   workspaces {
  #     name = "ubuntu-vm"
  #   }
  # }

  # Option 2: S3 Backend (Recommended for multi-machine/CI use)
  # Requires: S3 bucket and DynamoDB table for state locking
  # AWS credentials: Use environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
  # 
  # To enable, uncomment and configure the backend block below, or use -backend-config flags:
  #   terraform init -backend-config="bucket=your-bucket" -backend-config="region=us-east-1" -backend-config="dynamodb_table=your-table"
  #
  backend "s3" {
    bucket         = "com.cuffney.homelab-terraform"
    key            = "vms/ubuntu/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "homelab-terraform-locks"
    encrypt        = true
  }

  # Option 3: Keep local backend (NOT recommended for multi-machine use)
  # If no backend is specified, Terraform uses local backend
  # This will cause conflicts when using from multiple machines
}

# Provider configuration
# Note: Only authentication is required - all other values have sensible defaults.
# Variables can be set via terraform.tfvars or environment variables.
# The telmate/proxmox provider reads from PM_* environment variables if provider args are null.
# To use PROXMOX_* environment variables, provide values via terraform.tfvars instead.
provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_user             = var.proxmox_user
  pm_password         = var.proxmox_password
  pm_api_token_id     = var.proxmox_token_id
  pm_api_token_secret = var.proxmox_token_secret
  pm_tls_insecure     = var.proxmox_insecure
}

# Read cloud-init.yaml
# Dotfiles are now handled by bootstrap script via file provisioners
locals {
  cloud_init_content = file("${path.module}/../cloud-init.yaml")
}

# Create VM
resource "proxmox_vm_qemu" "ubuntu_vm" {
  name        = var.vm_name
  vmid        = var.vm_id
  description = "Minimal Ubuntu VM for general purpose projects"
  target_node = var.proxmox_target_node

  # Note: For cloud-init VMs, you need to either:
  # 1. Clone from a template (set vm_template variable)
  # 2. Or manually attach the cloud image in Proxmox UI after creation
  #    - Go to VM → Hardware → Add → CD/DVD Drive → Select cloud image
  #    - Go to VM → Options → Boot Order → Move CD/DVD to top
  clone = var.vm_template

  # CPU - Provider 3.0 syntax
  cpu {
    cores   = var.vm_cpu_cores
    sockets = 1
  }

  # Memory
  memory = var.vm_memory_mb

  # Disk - Provider 3.0 syntax
  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.vm_storage_pool
          size    = "${var.vm_disk_size_gb}G"
          format  = "raw"
        }
      }
    }
  }

  # Network - Provider 3.0 syntax
  network {
    id     = 0
    model  = "virtio"
    bridge = var.network_bridge
  }

  # Cloud-init configuration
  cicustom  = "user=${base64encode(local.cloud_init_content)}"
  ipconfig0 = "ip=dhcp"

  # BIOS and Machine type (standard, no GPU passthrough needed)
  bios    = "seabios"
  machine = "pc"

  # OS
  os_type = "cloud-init"
  qemu_os = "l26" # Linux 2.6+

  # Lifecycle
  lifecycle {
    ignore_changes = [
      network,
      disk,
    ]
  }

  # Connection configuration for provisioners
  # Note: Provisioners run after the VM is created and accessible via SSH
  # SSH key path should be absolute (e.g., /Users/username/.ssh/id_ed25519)
  # or relative to the Terraform working directory
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(pathexpand(var.ssh_private_key_path))
    host        = self.default_ipv4_address
    timeout     = "5m"
  }

  # Wait for VM to be accessible via SSH and cloud-init to complete
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait || true",
      "sleep 10"  # Additional wait to ensure system is ready
    ]
  }

  # Copy bootstrap script to VM
  provisioner "file" {
    source      = "${path.module}/../bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  # Copy shared dotfiles to VM
  provisioner "file" {
    source      = "${path.module}/../../dotfiles/"
    destination = "/tmp/dotfiles"
  }

  # Run bootstrap script to configure zsh and dotfiles
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "/tmp/bootstrap.sh"
    ]
  }
}
