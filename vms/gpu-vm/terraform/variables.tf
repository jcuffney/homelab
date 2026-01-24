variable "proxmox_api_url" {
  description = "Proxmox API endpoint URL"
  type        = string
  default     = null
  # Can be set via PM_API_URL environment variable
}

variable "proxmox_user" {
  description = "Proxmox username (e.g., root@pam or terraform@pve)"
  type        = string
  default     = null
  # Can be set via PM_USER environment variable
}

variable "proxmox_password" {
  description = "Proxmox password (optional, use with proxmox_user)"
  type        = string
  default     = null
  sensitive   = true
  # Can be set via PM_PASS environment variable
}

variable "proxmox_token_id" {
  description = "Proxmox API token ID (optional, for token-based auth)"
  type        = string
  default     = null
  # Can be set via PM_API_TOKEN_ID environment variable
}

variable "proxmox_token_secret" {
  description = "Proxmox API token secret (optional, for token-based auth)"
  type        = string
  default     = null
  sensitive   = true
  # Can be set via PM_API_TOKEN_SECRET environment variable
}

variable "proxmox_insecure" {
  description = "Allow insecure TLS connections to Proxmox"
  type        = bool
  default     = false
}

variable "proxmox_target_node" {
  description = "Proxmox node name where VM will be created"
  type        = string
  default     = "pve"
}

variable "vm_id" {
  description = "VM ID number (must be unique in Proxmox)"
  type        = number
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "numenor"
}

variable "vm_cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 4
}

variable "vm_memory_mb" {
  description = "RAM in MB"
  type        = number
  default     = 8192
}

variable "vm_disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 100
}

variable "vm_storage_pool" {
  description = "Storage pool name for VM disk"
  type        = string
  default     = "local-lvm"
}

variable "vm_iso_storage_pool" {
  description = "Storage pool name for cloud-init ISO"
  type        = string
  default     = "local"
}

variable "gpu_device_id" {
  description = "PCI device ID for GPU passthrough (e.g., 0000:01:00.0)"
  type        = string
}

variable "gpu_rombar" {
  description = "ROM bar setting (0 or 1, default 0 for passthrough)"
  type        = number
  default     = 0
}

variable "gpu_x_vga" {
  description = "Enable X-VGA (0 or 1, default 1 if primary GPU)"
  type        = number
  default     = 1
}

variable "network_bridge" {
  description = "Network bridge name (e.g., vmbr0)"
  type        = string
  default     = "vmbr0"
}


