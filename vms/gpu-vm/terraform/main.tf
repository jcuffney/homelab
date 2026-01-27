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
  #     name = "gpu-vm"
  #   }
  # }

  # Option 2: S3 Backend (If you have AWS)
  # Requires: S3 bucket and DynamoDB table for state locking
  # Uncomment and configure:
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "vms/gpu-vm/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }

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

# Read cloud-init.yaml and docker-compose.yml files
locals {
  cloud_init_content     = file("${path.module}/../cloud-init.yaml")
  docker_compose_content = file("${path.module}/../docker-compose.yml")

  # Inject docker-compose.yml into cloud-init as write_files
  # We append write_files section to the existing cloud-init content
  cloud_init_with_docker_compose = <<-EOT
${local.cloud_init_content}
write_files:
  - path: /srv/docker/docker-compose.yml
    content: |
${indent(6, local.docker_compose_content)}
    owner: root:root
    permissions: '0644'
EOT
}

# Create cloud-init ISO
resource "proxmox_vm_qemu" "gpu_vm" {
  name        = var.vm_name
  vmid        = var.vm_id
  description = "GPU VM for Ollama and Plex workloads"
  target_node = var.proxmox_target_node

  # CPU - Provider 3.0 syntax (cpu block instead of flat parameters)
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

  # Cloud-init
  cicustom  = "user=${base64encode(local.cloud_init_with_docker_compose)}"
  ipconfig0 = "ip=dhcp"

  # Note: For provider 3.0, cloud-init VMs typically clone from a template
  # You'll need to create a template from your cloud image first, then use:
  # clone = "template-name"
  # For now, we're using cicustom which should work without a template

  # BIOS and Machine type (required for GPU passthrough)
  bios    = "ovmf"
  machine = "q35"

  # GPU Passthrough - Provider 3.0 syntax
  # Note: GPU passthrough requires the GPU to be available on the Proxmox host
  # If GPU is already passed through to another VM, stop that VM first
  # If using raw_id, GPU must be mapped in Proxmox UI first OR use root user
  # Temporarily commented out - add GPU passthrough manually in Proxmox UI after VM creation
  # Or uncomment and map GPU in Proxmox UI first, then use mapping_id
  # pci {
  #   id     = 0
  #   raw_id = var.gpu_device_id
  # }

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
}
