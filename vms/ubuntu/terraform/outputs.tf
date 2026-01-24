# Output the VM's IP address for easy SSH access
# Note: Proxmox provider may not populate default_ipv4_address automatically
# Check Proxmox UI (Network tab) or your router's DHCP leases for the actual IP
output "vm_ip_address" {
  description = "IP address of the Ubuntu VM (from DHCP). Check Proxmox UI if empty."
  value       = proxmox_vm_qemu.ubuntu_vm.default_ipv4_address != "" ? proxmox_vm_qemu.ubuntu_vm.default_ipv4_address : "Check Proxmox UI → VM → Network tab"
}

output "vm_name" {
  description = "Name of the Ubuntu VM"
  value       = proxmox_vm_qemu.ubuntu_vm.name
}

output "vm_id" {
  description = "VM ID in Proxmox"
  value       = proxmox_vm_qemu.ubuntu_vm.vmid
}

output "ssh_command" {
  description = "SSH command to connect to the VM (once IP is available)"
  value       = try("ssh jcuffney@${proxmox_vm_qemu.ubuntu_vm.default_ipv4_address}", "IP not available yet - check Proxmox UI")
}

output "proxmox_ui_link" {
  description = "Link to view VM in Proxmox UI"
  value       = "https://192.168.1.10:8006/#v1:0:node=${proxmox_vm_qemu.ubuntu_vm.target_node}:4=${proxmox_vm_qemu.ubuntu_vm.vmid}"
}
