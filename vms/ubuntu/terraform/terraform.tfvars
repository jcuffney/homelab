# Minimal Required Configuration
# Only authentication is required - all other values have sensible defaults

# Proxmox Authentication (choose one method)

# Option 1: Password Authentication
# Uncomment and fill in:
# proxmox_password = "your-password-here"
# Uses defaults: proxmox_api_url = "https://192.168.1.10:8006/api2/json", proxmox_user = "root@pam"

# Option 2: API Token Authentication (Recommended)
# Uncomment and fill in:
proxmox_token_id     = "jcuffney@pam!terraform-token"
proxmox_token_secret = "8eb7bdb5-c92e-4ab6-8c4e-67e1fd4bf22e"
# Uses default: proxmox_api_url = "https://192.168.1.10:8006/api2/json"

# ============================================
# Optional: Override Defaults
# ============================================
# All values below have sensible defaults and don't need to be set unless you want to override them

# Allow insecure TLS (required for self-signed certificates or IP address access)
proxmox_insecure = true

# Proxmox Connection (if different from defaults)
# proxmox_api_url = "https://proxmox.example.com:8006/api2/json"
# proxmox_user    = "root@pam"
# proxmox_target_node = "numenor"  # Change to your actual Proxmox node name

# VM Configuration (defaults: vm_id=200, vm_name="ubuntu-vm", vm_cpu_cores=2, vm_memory_mb=4096, vm_disk_size_gb=50)
# vm_id          = 200
# vm_name        = "ubuntu-vm"
# vm_cpu_cores   = 2
# vm_memory_mb   = 4096
# vm_disk_size_gb = 50

# Storage Configuration (default: vm_storage_pool="local-lvm")
# vm_storage_pool = "local-lvm"

# Network Configuration (default: network_bridge="vmbr0")
# network_bridge = "vmbr0"

# Cloud-init Template (REQUIRED for cloud-init to work)
# Set this to your Proxmox cloud-init template name
# If you don't have a template yet, see README.md section "Cloud Image Setup" for instructions
# Example: vm_template = "ubuntu-24.04-cloudinit-template"
# vm_template = "your-template-name-here"
