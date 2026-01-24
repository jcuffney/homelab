# Networking Implementation Tasks

This document breaks down the networking plan into small, ordered, testable tasks. Complete each task in order and verify it works before moving to the next.

## Prerequisites

- OPNsense running on `192.168.1.1`
- Proxmox running on `192.168.1.10`
- Access to OPNsense Web UI
- Access to Proxmox Web UI
- SSH access to both systems

---

## Phase 1: DNS Configuration

### Task 1.1: Verify Unbound DNS is Enabled

**Objective**: Ensure OPNsense Unbound DNS service is running.

**Steps**:
1. Access OPNsense Web UI: `https://192.168.1.1`
2. Navigate to: **Services → Unbound DNS → General**
3. Verify **Enable Unbound** checkbox is checked
4. Verify **Listen Port** is `53` (default)
5. Click **Save** if any changes were made

**Test**:
```bash
# From any device on your network
dig @192.168.1.1 google.com
# Should return DNS results
```

**Expected Result**: DNS queries to OPNsense should resolve.

---

### Task 1.2: Configure Unbound DNS Settings

**Objective**: Configure Unbound with security and privacy features.

**Steps**:
1. In OPNsense: **Services → Unbound DNS → General**
2. Configure:
   - **Network Interfaces**: Select LAN interface
   - **Enable DNSSEC**: ✅ (check this)
   - **Enable DNS over TLS**: ✅ (optional, recommended)
   - **DNS over TLS Servers**: 
     - `1.1.1.1@853` (Cloudflare)
     - `1.0.0.1@853` (Cloudflare secondary)
   - **Enable Unbound Control**: ✅ (for management)
3. Click **Save**
4. Click **Apply Changes**

**Test**:
```bash
# Test DNS resolution
dig @192.168.1.1 google.com
# Should work with DNSSEC validation
```

**Expected Result**: DNS resolution works with DNSSEC enabled.

---

### Task 1.3: Configure DHCP to Use Unbound

**Objective**: Make all devices on your network use OPNsense as DNS server.

**Steps**:
1. In OPNsense: **Services → DHCPv4 → [LAN]**
2. Scroll to **DNS Servers** section
3. Configure:
   - **Primary DNS**: `192.168.1.1` (OPNsense/Unbound)
   - **Secondary DNS**: `1.1.1.1` (Cloudflare fallback)
   - **Tertiary DNS**: `1.0.0.1` (Cloudflare secondary)
4. Click **Save**
5. Click **Apply Changes**

**Test**:
```bash
# On a device that gets IP via DHCP
cat /etc/resolv.conf
# Should show: nameserver 192.168.1.1

# Test DNS resolution
nslookup google.com
# Should resolve using 192.168.1.1
```

**Expected Result**: DHCP clients use OPNsense as DNS server.

---

### Task 1.4: Configure Proxmox DNS

**Objective**: Configure Proxmox to use OPNsense DNS.

**Steps**:
1. Access Proxmox Web UI: `https://192.168.1.10:8006`
2. Navigate to: **Datacenter → [Your Node] → System → DNS**
3. Enter DNS servers (one per line):
   ```
   192.168.1.1
   1.1.1.1
   1.0.0.1
   ```
4. Click **OK**

**Test**:
```bash
# SSH into Proxmox
ssh root@192.168.1.10

# Check DNS configuration
cat /etc/resolv.conf
# Should show: nameserver 192.168.1.1

# Test DNS resolution
nslookup google.com
dig @192.168.1.1 google.com
```

**Expected Result**: Proxmox uses OPNsense DNS and can resolve domains.

---

### Task 1.5: Set Hostname on Proxmox

**Objective**: Set hostname on Proxmox for easy identification.

**Steps**:
1. SSH into Proxmox: `ssh root@192.168.1.10`
2. Set hostname:
   ```bash
   hostnamectl set-hostname proxmox
   ```
3. Verify:
   ```bash
   hostnamectl
   # Should show: Static hostname: proxmox
   ```

**Test**:
```bash
# Verify hostname
hostname
# Should output: proxmox
```

**Expected Result**: Proxmox hostname is set to `proxmox`.

---

### Task 1.6: Set Hostname on OPNsense

**Objective**: Set hostname on OPNsense for easy identification.

**Steps**:
1. Access OPNsense Web UI: `https://192.168.1.1`
2. Navigate to: **System → Settings → General**
3. Set:
   - **Hostname**: `opnsense`
   - **Domain**: `local` (or your preferred domain)
4. Click **Save**

**Test**:
```bash
# From OPNsense CLI (if accessible)
hostname
# Should output: opnsense
```

**Expected Result**: OPNsense hostname is set to `opnsense`.

---

### Task 1.7: Add DNS Override for Proxmox

**Objective**: Create DNS entry so `proxmox` resolves to `192.168.1.10`.

**Steps**:
1. In OPNsense: **Services → Unbound DNS → Overrides**
2. Click **Add** button
3. Configure:
   - **Host**: `proxmox`
   - **Domain**: (leave empty or use `local`)
   - **Type**: `A`
   - **Value**: `192.168.1.10`
   - **Description**: `Proxmox host`
4. Click **Save**
5. Click **Apply Changes**

**Test**:
```bash
# Test DNS resolution
nslookup proxmox
# Should resolve to: 192.168.1.10

dig @192.168.1.1 proxmox
# Should return: proxmox.  IN A 192.168.1.10
```

**Expected Result**: `proxmox` hostname resolves to `192.168.1.10`.

---

### Task 1.8: Add DNS Override for OPNsense

**Objective**: Create DNS entry so `opnsense` resolves to `192.168.1.1`.

**Steps**:
1. In OPNsense: **Services → Unbound DNS → Overrides**
2. Click **Add** button
3. Configure:
   - **Host**: `opnsense`
   - **Domain**: (leave empty or use `local`)
   - **Type**: `A`
   - **Value**: `192.168.1.1`
   - **Description**: `OPNsense router`
4. Click **Save**
5. Click **Apply Changes**

**Test**:
```bash
# Test DNS resolution
nslookup opnsense
# Should resolve to: 192.168.1.1

dig @192.168.1.1 opnsense
# Should return: opnsense.  IN A 192.168.1.1
```

**Expected Result**: `opnsense` hostname resolves to `192.168.1.1`.

---

### Task 1.9: Configure SSH Client Config (Local Machine)

**Objective**: Set up SSH config file for easy hostname-based access.

**Steps**:
1. On your local machine (laptop/desktop), create/edit SSH config:
   ```bash
   mkdir -p ~/.ssh
   touch ~/.ssh/config
   chmod 600 ~/.ssh/config
   nano ~/.ssh/config
   ```

2. Add the following entries:
   ```ssh-config
   # OPNsense Router
   Host opnsense
       HostName opnsense
       User root
       Port 22
       IdentityFile ~/.ssh/id_ed25519

   # Proxmox Host
   Host proxmox
       HostName proxmox
       User root
       Port 22
       IdentityFile ~/.ssh/id_ed25519
   ```

3. Adjust `IdentityFile` to match your SSH key path if different

**Test**:
```bash
# Test DNS resolution first
nslookup proxmox
nslookup opnsense

# Test SSH connection
ssh proxmox
# Should connect to Proxmox

ssh opnsense
# Should connect to OPNsense (if SSH is enabled)
```

**Expected Result**: Can SSH using hostnames: `ssh proxmox` and `ssh opnsense`.

---

### Task 1.10: Add DNS Overrides for VMs (As Needed)

**Objective**: Add DNS entries for your VMs as you create them.

**Steps**:
1. Determine VM IP address (from Proxmox UI or DHCP leases)
2. In OPNsense: **Services → Unbound DNS → Overrides**
3. Click **Add** button
4. Configure:
   - **Host**: `ubuntu-vm` (or your VM hostname)
   - **Domain**: (leave empty)
   - **Type**: `A`
   - **Value**: `192.168.1.X` (VM's IP address)
   - **Description**: `Ubuntu VM` (or descriptive name)
5. Click **Save**
6. Click **Apply Changes**

**Test**:
```bash
# Test DNS resolution
nslookup ubuntu-vm
# Should resolve to VM's IP

# Test SSH access
ssh jcuffney@ubuntu-vm
# Should connect to VM
```

**Expected Result**: VM hostname resolves and SSH works using hostname.

---

## Phase 2: WireGuard VPN Setup

### Task 2.1: Install WireGuard Plugin

**Objective**: Install WireGuard plugin on OPNsense.

**Steps**:
1. Access OPNsense Web UI: `https://192.168.1.1`
2. Navigate to: **System → Firmware → Plugins**
3. Search for: `os-wireguard`
4. Click **Install** button
5. Wait for installation to complete

**Test**:
```bash
# Verify plugin is installed
# Navigate to: VPN → WireGuard
# Should see WireGuard menu options
```

**Expected Result**: WireGuard plugin is installed and menu appears.

---

### Task 2.2: Configure WireGuard Server

**Objective**: Enable and configure WireGuard server on OPNsense.

**Steps**:
1. In OPNsense: **VPN → WireGuard → General Settings**
2. Enable WireGuard: ✅ (check the box)
3. Configure:
   - **Interface Name**: `wg0` (default)
   - **Listen Port**: `51820` (default)
   - **Private Key**: Click **Generate** button (or leave auto-generated)
   - **Public Key**: Will be generated automatically
4. Click **Save**

**Test**:
```bash
# Check WireGuard status
# Navigate to: VPN → WireGuard → Status
# Should show interface wg0
```

**Expected Result**: WireGuard server is enabled and configured.

---

### Task 2.3: Create WireGuard Interface

**Objective**: Create network interface for WireGuard VPN.

**Steps**:
1. In OPNsense: **Interfaces → Assignments**
2. Click **Add** button (or find WireGuard interface)
3. Select **WireGuard** as interface type
4. Configure:
   - **Interface Name**: `wg0`
   - **Description**: `WireGuard VPN`
5. Click **Save**

6. Configure interface IP:
   - Navigate to: **Interfaces → [wg0]**
   - **IPv4 Configuration Type**: Static IPv4
   - **IPv4 Address**: `10.10.0.1/24`
   - Click **Save**
   - Click **Apply Changes**

**Test**:
```bash
# Check interface exists
# Navigate to: Interfaces → Assignments
# Should see wg0 interface listed
```

**Expected Result**: WireGuard interface `wg0` is created with IP `10.10.0.1/24`.

---

### Task 2.4: Configure WAN Firewall Rule (Allow WireGuard)

**Objective**: Allow WireGuard VPN traffic from internet (ONLY public-facing service).

**Steps**:
1. In OPNsense: **Firewall → Rules → WAN**
2. Click **Add** button (create new rule at top)
3. Configure:
   - **Action**: `Pass`
   - **Interface**: `WAN`
   - **Protocol**: `UDP`
   - **Destination Port**: `51820`
   - **Description**: `Allow WireGuard VPN (ONLY public service)`
4. Click **Save**
5. Click **Apply Changes**

**Test**:
```bash
# Verify rule exists
# Navigate to: Firewall → Rules → WAN
# Should see rule allowing UDP port 51820
```

**Expected Result**: WAN firewall allows WireGuard traffic on port 51820.

---

### Task 2.5: Verify WAN Firewall Blocks Other Traffic

**Objective**: Ensure no other services are accessible from internet.

**Steps**:
1. In OPNsense: **Firewall → Rules → WAN**
2. Review existing rules
3. Verify:
   - Only WireGuard (UDP 51820) rule allows traffic
   - Default deny rule exists (should be automatic)
   - No rules allowing HTTP (80), HTTPS (443), or other services

**Test**:
```bash
# From a device NOT on your network (mobile data):
# These should ALL fail:
curl http://your-public-ip:80      # Should timeout/fail
curl http://your-public-ip:443    # Should timeout/fail
curl http://your-public-ip:8006    # Should timeout/fail
```

**Expected Result**: Only WireGuard port is accessible from internet.

---

### Task 2.6: Configure WireGuard Firewall Rules

**Objective**: Allow VPN clients to access LAN services.

**Steps**:
1. In OPNsense: **Firewall → Rules → WireGuard**
2. Click **Add** button
3. Create Rule 1: Allow VPN to LAN
   - **Action**: `Pass`
   - **Interface**: `WireGuard`
   - **Source**: `WireGuard net` (`10.10.0.0/24`)
   - **Destination**: `LAN net` (`192.168.1.0/24`)
   - **Description**: `Allow VPN clients to access LAN`
4. Click **Save**

5. Create Rule 2: Allow VPN Internet Access (Optional)
   - **Action**: `Pass`
   - **Interface**: `WireGuard`
   - **Source**: `WireGuard net` (`10.10.0.0/24`)
   - **Destination**: `Any`
   - **Description**: `Allow VPN clients internet access`
6. Click **Save**
7. Click **Apply Changes**

**Test**:
```bash
# After connecting VPN client:
# Test will be done in Task 2.11
```

**Expected Result**: Firewall rules allow VPN clients to access LAN.

---

### Task 2.7: Configure NAT for WireGuard

**Objective**: Enable NAT so VPN clients can access internet (if desired).

**Steps**:
1. In OPNsense: **Firewall → NAT → Outbound**
2. Verify **Mode** is set to **Automatic** (default)
3. If not automatic, ensure rule exists:
   - **Interface**: `WAN`
   - **Source**: `WireGuard net` (`10.10.0.0/24`)
   - **Destination**: `Any`
   - **NAT Address**: `WAN address`

**Test**:
```bash
# After connecting VPN client:
# Test will be done in Task 2.11
```

**Expected Result**: NAT is configured for VPN clients.

---

### Task 2.8: Create WireGuard Endpoint

**Objective**: Create endpoint configuration for WireGuard server.

**Steps**:
1. In OPNsense: **VPN → WireGuard → Endpoints**
2. Click **Add** button
3. Configure:
   - **Name**: `OPNsense-WireGuard`
   - **Public Key**: Copy from **VPN → WireGuard → General Settings**
   - **Allowed IPs**: `10.10.0.0/24`
   - **Endpoint Address**: Your public IP or domain name
   - **Endpoint Port**: `51820`
   - **Persistent Keepalive**: `25` (seconds)
4. Click **Save**

**Test**:
```bash
# Verify endpoint exists
# Navigate to: VPN → WireGuard → Endpoints
# Should see endpoint listed
```

**Expected Result**: WireGuard endpoint is configured.

---

### Task 2.9: Create First WireGuard Client

**Objective**: Create client configuration for your device.

**Steps**:
1. In OPNsense: **VPN → WireGuard → Local**
2. Click **Add** button
3. Configure:
   - **Name**: `laptop` (or descriptive name)
   - **Public Key**: Will be generated automatically
   - **Private Key**: Will be generated automatically
   - **Allowed IPs**: `10.10.0.2/32` (unique IP for this client)
   - **Description**: `My Laptop`
4. **Link to Endpoint**: Select endpoint from Task 2.8
5. Click **Save**

**Test**:
```bash
# Verify client exists
# Navigate to: VPN → WireGuard → Local
# Should see client listed
```

**Expected Result**: WireGuard client is created.

---

### Task 2.10: Export and Import Client Configuration

**Objective**: Get WireGuard config file for your device.

**Steps**:
1. In OPNsense: **VPN → WireGuard → Local**
2. Click on the client you created (Task 2.9)
3. Click **Show QR Code** or **Download Config**
4. If downloading:
   - Save the `.conf` file
   - Edit the file and ensure it includes:
     ```
     [Interface]
     ...
     DNS = 192.168.1.1
     ```
   - If DNS is missing, add it manually
5. Import into WireGuard client on your device:
   - **iOS/Android**: Scan QR code or import config file
   - **Windows/Mac/Linux**: Import config file into WireGuard app

**Test**:
```bash
# After importing, connect to VPN
# Verify connection status in WireGuard app
```

**Expected Result**: WireGuard config is imported and ready to connect.

---

### Task 2.11: Test VPN Connection

**Objective**: Verify VPN connection works and can access LAN services.

**Steps**:
1. Connect to WireGuard VPN on your device
2. Verify connection status shows "Connected"

**Test**:
```bash
# From VPN-connected device:

# Test basic connectivity
ping 192.168.1.1      # OPNsense - should work
ping 192.168.1.10     # Proxmox - should work
ping 10.10.0.1        # VPN gateway - should work

# Test DNS resolution
nslookup proxmox
# Should resolve to 192.168.1.10

nslookup opnsense
# Should resolve to 192.168.1.1

# Test SSH access using hostnames
ssh proxmox
# Should connect to Proxmox

# Test service access
curl https://192.168.1.10:8006
# Should access Proxmox Web UI
```

**Expected Result**: VPN connection works and can access all LAN services.

---

### Task 2.12: Verify Services NOT Accessible Without VPN

**Objective**: Confirm services are NOT accessible from public internet.

**Steps**:
1. Disconnect from VPN
2. Use mobile data (or different network) to test

**Test**:
```bash
# From device NOT connected to VPN (using mobile data):

# These should ALL fail (timeout or connection refused):
curl http://your-public-ip:32400      # Plex - should fail
curl https://your-public-ip:443      # HTTPS - should fail
curl http://your-public-ip:8006       # Proxmox - should fail
ssh jcuffney@proxmox                  # SSH - should fail (no DNS)

# Only WireGuard should work:
# WireGuard connection on port 51820/UDP should connect
```

**Expected Result**: Services are NOT accessible without VPN connection.

---

### Task 2.13: Port Forwarding (If Behind NAT)

**Objective**: Forward WireGuard port if OPNsense is behind another router.

**Steps**:
1. Access your upstream router's admin interface
2. Navigate to Port Forwarding/Virtual Server settings
3. Create port forward rule:
   - **External Port**: `51820` (UDP)
   - **Internal IP**: `192.168.1.1` (OPNsense)
   - **Internal Port**: `51820`
   - **Protocol**: `UDP`
   - **Description**: `WireGuard VPN`
4. Save and apply changes

**Test**:
```bash
# From external network, try connecting WireGuard
# Should connect successfully
```

**Expected Result**: WireGuard works from external networks.

---

## Phase 3: TLS/SSL Certificate Management (Optional)

### Task 3.1: Choose TLS Solution

**Objective**: Decide which TLS solution to use.

**Options**:
- **Option A**: OPNsense ACME plugin (for OPNsense services)
- **Option B**: Traefik reverse proxy (recommended for VM services)
- **Option C**: Nginx Proxy Manager (alternative with web UI)

**Decision**: Choose based on your needs. For VM services, Option B (Traefik) is recommended.

---

### Task 3.2: Install ACME Plugin (If Using Option A)

**Objective**: Install ACME client plugin on OPNsense.

**Steps**:
1. In OPNsense: **System → Firmware → Plugins**
2. Search for: `os-acme-client`
3. Click **Install**
4. Wait for installation

**Test**:
```bash
# Verify plugin installed
# Navigate to: Services → ACME Client
# Should see ACME Client menu
```

**Expected Result**: ACME plugin is installed.

---

### Task 3.3: Configure ACME Account (If Using Option A)

**Objective**: Set up Let's Encrypt account.

**Steps**:
1. In OPNsense: **Services → ACME Client → Accounts**
2. Click **Add**
3. Configure:
   - **Name**: `Let's Encrypt`
   - **ACME CA**: `Let's Encrypt (Production)`
   - **E-Mail**: Your email address
   - **ACME Agreement**: Accept terms
4. Click **Save**

**Test**:
```bash
# Verify account created
# Navigate to: Services → ACME Client → Accounts
# Should see account listed
```

**Expected Result**: ACME account is configured.

---

### Task 3.4: Create Certificate (If Using Option A)

**Objective**: Generate SSL certificate using DNS-01 challenge.

**Steps**:
1. In OPNsense: **Services → ACME Client → Certificates**
2. Click **Add**
3. Configure:
   - **Name**: `homelab-cert`
   - **Account**: Select account from Task 3.3
   - **Domain**: `yourdomain.com` or `*.yourdomain.com` (wildcard)
   - **Challenge Type**: `DNS-01` (NOT HTTP-01)
   - **DNS API**: Configure your DNS provider (Cloudflare, etc.)
4. Click **Save**
5. Click **Issue/Renew** to generate certificate

**Test**:
```bash
# Verify certificate created
# Navigate to: Services → ACME Client → Certificates
# Should see certificate with valid expiration date
```

**Expected Result**: SSL certificate is generated and ready to use.

---

## Testing Checklist

After completing all tasks, verify:

- [ ] DNS resolution works: `nslookup proxmox`, `nslookup opnsense`
- [ ] SSH works using hostnames: `ssh proxmox`, `ssh opnsense`
- [ ] VPN connects successfully from external network
- [ ] VPN clients can access LAN services (Proxmox, VMs, etc.)
- [ ] VPN clients can resolve hostnames (proxmox, opnsense, VMs)
- [ ] Services are NOT accessible from public internet (without VPN)
- [ ] Only WireGuard port (51820/UDP) is accessible from internet

---

## Notes

- Complete tasks in order - each task builds on previous ones
- Test each task before moving to the next
- If a task fails, troubleshoot before continuing
- Keep notes of any customizations or deviations
- Backup OPNsense configuration after major changes

---

## Troubleshooting Quick Reference

**DNS not resolving**:
- Check Unbound is enabled: `Services → Unbound DNS → General`
- Verify DNS override exists: `Services → Unbound DNS → Overrides`
- Test: `dig @192.168.1.1 proxmox`

**SSH not working with hostname**:
- Verify DNS resolution: `nslookup proxmox`
- Check SSH config: `~/.ssh/config`
- Test with IP: `ssh root@192.168.1.10`

**VPN not connecting**:
- Check WireGuard status: `VPN → WireGuard → Status`
- Verify firewall rules allow port 51820
- Check port forwarding if behind NAT
- Review WireGuard logs: `VPN → WireGuard → Log File`

**Services accessible from internet**:
- Review WAN firewall rules
- Ensure only port 51820 is forwarded
- Test from mobile data to verify blocking
