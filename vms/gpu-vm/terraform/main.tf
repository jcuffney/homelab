terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9.0"
    }
  }
}

# Provider configuration
# The Proxmox provider will automatically read from environment variables if these are null:
# PM_API_URL, PM_USER, PM_PASS (or PM_API_TOKEN_ID + PM_API_TOKEN_SECRET)
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
  desc        = "GPU VM for Ollama and Plex workloads"
  target_node = var.proxmox_target_node

  # CPU and Memory
  cores   = var.vm_cpu_cores
  memory  = var.vm_memory_mb
  sockets = 1

  # Disk
  disk {
    type    = "scsi"
    storage = var.vm_storage_pool
    size    = "${var.vm_disk_size_gb}G"
    format  = "raw"
  }

  # Network
  network {
    bridge = var.network_bridge
    model  = "virtio"
  }

  # Cloud-init
  cicustom = "user=${base64encode(local.cloud_init_with_docker_compose)}"
  ipconfig0 = "ip=dhcp"
  
  # Cloud-init ISO storage
  cloudinit_cdrom_storage = var.vm_iso_storage_pool

  # BIOS and Machine type (required for GPU passthrough)
  bios    = "ovmf"
  machine = "q35"

  # GPU Passthrough
  hostpci {
    host   = var.gpu_device_id
    pcie   = 1
    x_vga  = var.gpu_x_vga
    rombar = var.gpu_rombar
  }

  # OS
  os_type = "cloud-init"
  qemu_os  = "l26" # Linux 2.6+

  # Lifecycle
  lifecycle {
    ignore_changes = [
      network,
      disk,
    ]
  }
}
