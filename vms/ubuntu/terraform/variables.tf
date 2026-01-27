variable "proxmox_api_url" {
  description = "Proxmox API endpoint URL"
  type        = string
  default     = "https://192.168.1.10:8006/api2/json"
  # Can be set via PROXMOX_API_URL environment variable
  # Note: If using hostname (e.g., numenor.cuffney.com), ensure DNS resolves or add to /etc/hosts
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
  default     = "numenor"
}

variable "vm_id" {
  description = "VM ID number (must be unique in Proxmox)"
  type        = number
  default     = 200
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "ubuntu-vm"
}

variable "vm_cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "vm_memory_mb" {
  description = "RAM in MB"
  type        = number
  default     = 4096
}

variable "vm_disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 50
}

variable "vm_storage_pool" {
  description = "Storage pool name for VM disk"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Network bridge name (e.g., vmbr0)"
  type        = string
  default     = "vmbr0"
}

variable "vm_template" {
  description = "Proxmox template name to clone from (e.g., ubuntu-24.04-cloudinit-template). If not set, VM will be created without a bootable image."
  type        = string
  default     = null
  # To create a template:
  # 1. Create a VM manually in Proxmox UI
  # 2. Attach the cloud image as a disk
  # 3. Boot and configure it
  # 4. Convert to template: Right-click VM → Convert to Template
}

# S3 Backend Configuration
# These variables are used to configure the Terraform S3 backend for shared state
# AWS credentials should be provided via environment variables:
#   - AWS_ACCESS_KEY_ID
#   - AWS_SECRET_ACCESS_KEY
#   - AWS_SESSION_TOKEN (optional, for temporary credentials)

variable "s3_backend_bucket" {
  description = "S3 bucket name for Terraform state storage"
  type        = string
  default     = null
  # Example: "my-terraform-state-bucket"
}

variable "s3_backend_region" {
  description = "AWS region for S3 backend"
  type        = string
  default     = "us-east-1"
  # Example: "us-east-1", "us-west-2", "eu-west-1"
}

variable "s3_backend_dynamodb_table" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = null
  # Example: "terraform-state-lock"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for VM provisioning (used by file and remote-exec provisioners). Can use ~ for home directory."
  type        = string
  default     = "~/.ssh/id_ed25519"
  # Can be overridden in terraform.tfvars or via -var flag
  # Example: "~/.ssh/id_ed25519" or "/Users/username/.ssh/id_ed25519"
  # Note: ~ will be expanded to $HOME environment variable
}
