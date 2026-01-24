# Minimal Required Configuration
# Only authentication is required - all other values have sensible defaults

# Proxmox Authentication (choose one method)

# Option 1: Password Authentication
# Uncomment and fill in (only works for pam realm users):
# proxmox_user = "jcuffney@pam"
# proxmox_password = "your-password"
# Uses default: proxmox_api_url = "https://192.168.1.10:8006/api2/json"

# Option 2: API Token Authentication (Recommended)
# Uncomment and fill in:
proxmox_user         = "jcuffney@pam"                         # Must match the realm in token_id
proxmox_token_id     = "jcuffney@pam!terraform-token"         # Token ID format: user@realm!token-name
proxmox_token_secret = "8eb7bdb5-c92e-4ab6-8c4e-67e1fd4bf22e" # Token secret from Proxmox
# Uses default: proxmox_api_url = "https://192.168.1.10:8006/api2/json"

# ============================================
# Optional: Override Defaults
# ============================================
# All values below have sensible defaults and don't need to be set unless you want to override them

# Proxmox Connection (if different from defaults)
# Uncomment and set the correct Proxmox API URL:
# proxmox_api_url = "https://YOUR_PROXMOX_IP:8006/api2/json"
# Example: proxmox_api_url = "https://192.168.1.100:8006/api2/json"
# proxmox_user    = "root@pam"
# proxmox_target_node = "pve"

# Allow insecure TLS (required for self-signed certificates)
proxmox_insecure = true

# VM Configuration (defaults: vm_id=100, vm_name="rivendell", vm_cpu_cores=12, vm_memory_mb=32768, vm_disk_size_gb=750)
# vm_id          = 100
# vm_name        = "rivendell"
# vm_cpu_cores   = 4
# vm_memory_mb   = 8192
# vm_disk_size_gb = 100

# Storage Configuration (defaults: vm_storage_pool="local-lvm", vm_iso_storage_pool="local")
# vm_storage_pool     = "local-lvm"
# vm_iso_storage_pool = "local"

# GPU Configuration (defaults: gpu_device_id="0000:3b:00.0", gpu_rombar=0, gpu_x_vga=1)
# gpu_device_id = "0000:3b:00.0"
# gpu_rombar    = 0
# gpu_x_vga     = 1

# Cloud Image (default: "ubuntu-24.04-server-cloudimg-amd64.img")
# IMPORTANT: Must be a cloud image (.img file), not a live server ISO
# Download from: https://cloud-images.ubuntu.com/
# Upload to Proxmox: Datacenter → Node → Storage → ISO Images
# vm_cloud_image = "ubuntu-24.04-server-cloudimg-amd64.img"

# Network Configuration (default: network_bridge="vmbr0")
# network_bridge = "vmbr0"
