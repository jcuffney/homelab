variable "proxmox_api_url" {
  description = "Proxmox API endpoint URL"
  type        = string
  default     = "https://192.168.1.10:8006/api2/json"
  # Can be set via PROXMOX_API_URL environment variable
}

variable "proxmox_user" {
  description = "Proxmox username (e.g., root@pam or terraform@pve)"
  type        = string
  default     = "root@pam"
  # @pam is the authentication realm (Pluggable Authentication Module, uses system Linux authentication). Other realms include @pve, @ldap, etc.
  # Can be set via PROXMOX_USER environment variable
}

variable "proxmox_password" {
  description = "Proxmox password (optional, use with proxmox_user)"
  type        = string
  default     = null
  sensitive   = true
  # Can be set via PROXMOX_PASS environment variable
}

variable "proxmox_token_id" {
  description = "Proxmox API token ID (optional, for token-based auth)"
  type        = string
  default     = null
  # Can be set via PROXMOX_API_TOKEN_ID environment variable
}

variable "proxmox_token_secret" {
  description = "Proxmox API token secret (optional, for token-based auth)"
  type        = string
  default     = null
  sensitive   = true
  # Can be set via PROXMOX_API_TOKEN_SECRET environment variable
}

variable "proxmox_insecure" {
  description = "Allow insecure TLS connections to Proxmox"
  type        = bool
  default     = false
}

variable "proxmox_target_node" {
  description = "Proxmox node name where VM will be created"
  type        = string
  default     = "numenor" # Updated to match your Proxmox hostname
}

variable "vm_id" {
  description = "VM ID number (must be unique in Proxmox)"
  type        = number
  default     = 100
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "rivendell"
}

variable "vm_cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 12
}

variable "vm_memory_mb" {
  description = "RAM in MB"
  type        = number
  default     = 32768
}

variable "vm_disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 750
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
  description = "PCI device ID for GPU passthrough (e.g., 0000:01:00.0). Use raw_id format."
  type        = string
  default     = "0000:3b:00.0"
}

variable "gpu_mapping_id" {
  description = "GPU mapping ID if GPU is pre-mapped in Proxmox UI (alternative to gpu_device_id)"
  type        = string
  default     = null
  # If GPU is mapped in Proxmox UI (Hardware → PCI Device), use mapping_id instead of raw_id
  # This avoids the "only root can set hostpci0" error
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

variable "vm_cloud_image" {
  description = "Cloud image name in Proxmox storage (e.g., ubuntu-24.04-server-cloudimg-amd64.img)"
  type        = string
  default     = "ubuntu-24.04-server-cloudimg-amd64.img"
  # This references a cloud image (.img file) already uploaded to Proxmox storage
  # Cloud images are required for cloud-init to work properly (not live server ISOs)
  # Format: Just the filename if in default ISO storage, or "storage:filename" format
  # Find the image name in Proxmox UI: Datacenter → Node → Storage → ISO Images
  # Download cloud images from: https://cloud-images.ubuntu.com/
}

