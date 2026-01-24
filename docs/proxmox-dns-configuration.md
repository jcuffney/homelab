# Proxmox DNS Configuration with OPNsense

This guide covers how to configure DNS for your Proxmox cluster (192.168.1.10) when using OPNsense as your router.

## Overview

There are two main approaches to configure DNS for Proxmox:
1. **Via OPNsense DHCP** (if Proxmox uses DHCP) - Recommended
2. **Directly on Proxmox host** (if using static IP)

## Option 1: Configure DNS via OPNsense DHCP (Recommended)

If your Proxmox cluster receives its IP address via DHCP from OPNsense, configure DNS servers in OPNsense:

### Steps:

1. **Access OPNsense Web Interface**
   - Navigate to: `https://your-opnsense-ip` (typically 192.168.1.1)

2. **Configure DHCP DNS Servers**
   - Go to: **Services → DHCPv4 → [LAN]**
   - Scroll to **DNS Servers** section
   - Add your preferred DNS servers:
     - **Cloudflare**: `1.1.1.1` and `1.0.0.1`
     - **Google**: `8.8.8.8` and `8.8.4.4`
     - **OPNsense (if using Unbound)**: `192.168.1.1` (your OPNsense IP)
     - **Quad9**: `9.9.9.9` and `149.112.112.112`

3. **Save and Apply**
   - Click **Save**
   - Click **Apply Changes**

4. **Renew DHCP Lease on Proxmox**
   - SSH into your Proxmox node: `ssh root@192.168.1.10`
   - Renew DHCP lease:
     ```bash
     # For systemd-networkd
     sudo systemctl restart systemd-networkd
     
     # Or release and renew DHCP
     sudo dhclient -r && sudo dhclient
     ```

5. **Verify DNS Configuration**
   ```bash
   cat /etc/resolv.conf
   # Should show your configured DNS servers
   
   # Test DNS resolution
   nslookup google.com
   dig @1.1.1.1 google.com
   ```

## Option 2: Configure DNS Directly on Proxmox (Static IP)

If your Proxmox cluster uses a static IP address, configure DNS directly on each Proxmox node:

### Steps:

1. **SSH into Proxmox Node**
   ```bash
   ssh root@192.168.1.10
   ```

2. **Edit Network Configuration**
   
   Proxmox uses `/etc/network/interfaces` for network configuration:
   
   ```bash
   nano /etc/network/interfaces
   ```
   
   Find your network interface (typically `vmbr0`) and add DNS servers:
   
   ```
   auto vmbr0
   iface vmbr0 inet static
       address 192.168.1.10/24
       gateway 192.168.1.1
       bridge_ports enp3s0
       bridge_stp off
       bridge_fd 0
       dns-nameservers 1.1.1.1 1.0.0.1 8.8.8.8
   ```
   
   Or if using DHCP:
   ```
   auto vmbr0
   iface vmbr0 inet dhcp
       bridge_ports enp3s0
       bridge_stp off
       bridge_fd 0
       dns-nameservers 1.1.1.1 1.0.0.1
   ```

3. **Alternative: Edit resolv.conf directly** (temporary, may be overwritten)
   
   ```bash
   nano /etc/resolv.conf
   ```
   
   Add:
   ```
   nameserver 1.1.1.1
   nameserver 1.0.0.1
   nameserver 8.8.8.8
   ```

4. **Restart Networking**
   ```bash
   # Restart networking service
   systemctl restart networking
   
   # Or restart the specific interface
   ifdown vmbr0 && ifup vmbr0
   ```

5. **Verify DNS Configuration**
   ```bash
   cat /etc/resolv.conf
   nslookup google.com
   ```

## Option 3: Configure DNS via Proxmox Web UI

You can also configure DNS through the Proxmox web interface:

1. **Access Proxmox Web UI**
   - Navigate to: `https://192.168.1.10:8006`

2. **Configure DNS**
   - Go to: **Datacenter → [Your Node] → System → DNS**
   - Enter DNS servers (one per line):
     ```
     1.1.1.1
     1.0.0.1
     8.8.8.8
     ```
   - Click **OK**

3. **Apply Changes**
   - The changes will be written to `/etc/resolv.conf` and network configuration

## Recommended DNS Servers

### Public DNS Options:
- **Cloudflare** (Fast, privacy-focused): `1.1.1.1`, `1.0.0.1`
- **Google** (Reliable): `8.8.8.8`, `8.8.4.4`
- **Quad9** (Security-focused): `9.9.9.9`, `149.112.112.112`
- **OpenDNS**: `208.67.222.222`, `208.67.220.220`

### Local DNS (if using OPNsense Unbound):
- **OPNsense Unbound**: `192.168.1.1` (your OPNsense IP)

## For Proxmox Cluster

If you have a multi-node Proxmox cluster, configure DNS on **each node**:

1. Repeat the configuration steps on each cluster node
2. Ensure all nodes can resolve each other's hostnames
3. Consider adding entries to `/etc/hosts` for cluster nodes:
   ```
   192.168.1.10  proxmox-01.local proxmox-01
   192.168.1.11  proxmox-02.local proxmox-02
   192.168.1.12  proxmox-03.local proxmox-03
   ```

## Troubleshooting

### Check Current DNS Configuration
```bash
cat /etc/resolv.conf
systemd-resolve --status  # If using systemd-resolved
```

### Test DNS Resolution
```bash
# Test with nslookup
nslookup google.com

# Test with dig
dig @1.1.1.1 google.com

# Test with host
host google.com
```

### Check Network Interface Configuration
```bash
cat /etc/network/interfaces
ip addr show
```

### Verify DNS in Proxmox
```bash
# Check Proxmox DNS settings
pvecm status
pvecm expected 1  # Adjust for your cluster size
```

## Notes

- If using OPNsense Unbound as a local DNS resolver, use `192.168.1.1` as your primary DNS server
- For cluster communication, ensure all nodes can resolve each other's hostnames
- DNS changes may take a few minutes to propagate
- Restart networking services after making changes
