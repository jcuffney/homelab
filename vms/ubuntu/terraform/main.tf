terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
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

# Read cloud-init.yaml and dotfiles
locals {
  cloud_init_content = file("${path.module}/../cloud-init.yaml")
  
  # Read VM-specific dotfiles
  dotfiles_bashrc      = file("${path.module}/../dotfiles/bashrc")
  dotfiles_bash_aliases = file("${path.module}/../dotfiles/bash_aliases")
  dotfiles_profile     = file("${path.module}/../dotfiles/profile")

  # Inject dotfiles into cloud-init as write_files
  # Dotfiles are VM-specific and stored in this VM's dotfiles directory
  cloud_init_with_dotfiles = <<-EOT
${local.cloud_init_content}
write_files:
  # Dotfiles for root user
  - path: /root/.bashrc
    content: |
${indent(6, local.dotfiles_bashrc)}
    owner: root:root
    permissions: '0644'
  - path: /root/.bash_aliases
    content: |
${indent(6, local.dotfiles_bash_aliases)}
    owner: root:root
    permissions: '0644'
  - path: /root/.profile
    content: |
${indent(6, local.dotfiles_profile)}
    owner: root:root
    permissions: '0644'
  # Dotfiles for jcuffney user
  - path: /home/jcuffney/.bashrc
    content: |
${indent(6, local.dotfiles_bashrc)}
    owner: jcuffney:jcuffney
    permissions: '0644'
  - path: /home/jcuffney/.bash_aliases
    content: |
${indent(6, local.dotfiles_bash_aliases)}
    owner: jcuffney:jcuffney
    permissions: '0644'
  - path: /home/jcuffney/.profile
    content: |
${indent(6, local.dotfiles_profile)}
    owner: jcuffney:jcuffney
    permissions: '0644'
EOT
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

  # Cloud-init (with shared dotfiles injected)
  cicustom  = "user=${base64encode(local.cloud_init_with_dotfiles)}"
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
}
