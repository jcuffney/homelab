# Homelab Networking Architecture

## Overview

This directory contains the networking setup plans and implementation tasks for the homelab infrastructure.

**Network Architecture:**
- **OPNsense** (shire): `192.168.1.1` - Router/Firewall with Unbound DNS
- **Proxmox** (numenor): `192.168.1.10` - Virtualization platform
- **LAN Network**: `192.168.1.0/24`
- **VPN Network**: `10.10.0.0/24` (WireGuard)
- **Domain**: `cuffney.com` (hosted in AWS Route 53)

## Naming Convention

All hosts use **dual naming** (both required):
- **Descriptive names**: `opnsense`, `proxmox`, `ubuntu-vm`
- **Themed names**: `shire`, `numenor`, `rivendell` (Middle Earth places)
- Both names resolve to the same IP and can be used interchangeably

See `.cursorrules` for full naming convention details.

## Search Domains

A **search domain** is a convenience feature that allows you to use short hostnames instead of full FQDNs (Fully Qualified Domain Names). Your system automatically appends the search domain to hostnames that don't include a domain.

### How It Works

When you type a hostname without a domain, your system automatically tries appending the search domain:

**Example with search domain `cuffney.com`:**
```bash
# You type:
ssh jcuffney@numenor

# System automatically tries:
numenor.cuffney.com  # ✅ Works!
```

**Without search domain:**
```bash
# You type:
ssh jcuffney@numenor

# System doesn't know what "numenor" means - might fail ❌
```

### Benefits

- **Shorter Commands**: `ssh numenor` instead of `ssh numenor.cuffney.com`
- **Less Typing**: `ping shire` instead of `ping shire.cuffney.com`
- **Works with Local Hostnames**: `curl http://proxmox:8006` instead of `curl http://proxmox.cuffney.com:8006`
- **Consistent Experience**: Same short hostnames work across all devices

### Configuration

The search domain is configured in **OPNsense** and automatically distributed to all devices via DHCP:

1. **Location**: `Services → ISC DHCPv4 → [LAN]`
2. **Field**: **Domain** (or **Domain Name**)
3. **Value**: `cuffney.com`
4. **Distribution**: All devices that get IPs via DHCP automatically receive this search domain

### Verification

**On Linux/Unix:**
```bash
cat /etc/resolv.conf
# Should show: search cuffney.com
```

**On macOS:**
```bash
scutil --dns
# Look for: search domain[0] : cuffney.com
```

### Examples

With `cuffney.com` as the search domain:
- `ssh numenor` → automatically resolves to `numenor.cuffney.com` → `192.168.1.10`
- `ssh shire` → automatically resolves to `shire.cuffney.com` → `192.168.1.1`
- `ping proxmox` → automatically resolves to `proxmox.cuffney.com` → `192.168.1.10`
- `curl http://numenor:8006` → automatically resolves to `numenor.cuffney.com:8006`

### Multiple Search Domains

You can configure multiple search domains. The system tries them in order:
1. `cuffney.com` (primary)
2. `local` (fallback, if configured)

If `numenor.cuffney.com` doesn't resolve, the system tries `numenor.local`.

## Security Model

**CRITICAL**: This setup ensures that **NO services are exposed to the public internet**. All remote access is **ONLY** via WireGuard VPN.

### Access Model
- **Local Network (192.168.1.0/24)**: Full access to all services
- **VPN Network (10.10.0.0/24)**: Full access to LAN services when connected via WireGuard
- **Public Internet**: **NO access** to any services except WireGuard VPN port (51820/UDP)

### Security Checklist
- [ ] **ONLY port 51820/UDP** is forwarded/exposed to the internet (WireGuard)
- [ ] **NO port forwarding** for HTTP (80), HTTPS (443), Plex (32400), Proxmox (8006), or any other services
- [ ] **WAN firewall rules** block all inbound traffic except WireGuard
- [ ] **LAN firewall rules** prevent WAN → LAN access
- [ ] **Services are only accessible** from LAN (192.168.1.0/24) and VPN (10.10.0.0/24)
- [ ] **Test from public internet** (mobile data) to verify services are NOT accessible

## Benefits

This networking setup provides several key advantages:

### Privacy & Security

- **Encrypted DNS Queries**: DNS over TLS (DoT) encrypts all DNS queries to Cloudflare, preventing your ISP from seeing which websites you're looking up
- **No Public Exposure**: Services are completely hidden from the internet - only accessible via VPN or local network
- **DNSSEC Validation**: Ensures DNS responses are authentic and haven't been tampered with
- **Single Point of Entry**: Only WireGuard VPN port (51820/UDP) is exposed, minimizing attack surface

### Performance & Reliability

- **Local DNS Caching**: Unbound caches DNS responses locally, reducing latency for frequently accessed domains
- **Fast DNS Resolution**: Cloudflare's DNS servers (1.1.1.1) are among the fastest globally
- **Redundancy**: Secondary DNS servers provide fallback if primary fails
- **Local Hostname Resolution**: Custom DNS overrides allow easy access using friendly names (e.g., `shire.cuffney.com` instead of `192.168.1.1`)

### Convenience & Usability

- **FQDN-Based Access**: Use domain names like `ssh jcuffney@numenor.cuffney.com` instead of IP addresses
- **Dual Naming System**: Both descriptive (`proxmox`) and themed (`numenor`) hostnames work
- **VPN Access Anywhere**: Securely access your entire home network from anywhere in the world
- **Consistent Experience**: Same hostnames work both locally and via VPN
- **Easy Service Discovery**: All devices automatically use OPNsense DNS via DHCP

### Network Architecture Benefits

- **Centralized DNS Management**: All DNS configuration in one place (OPNsense)
- **Automatic Configuration**: DHCP automatically configures devices with correct DNS servers
- **Domain Integration**: Seamless integration with your domain (`cuffney.com`) for professional hostnames
- **Scalable**: Easy to add new hosts/VMs - just add DNS overrides

### How It Works

**DNS Flow:**
```
Device → OPNsense Unbound → [Encrypted TLS] → Cloudflare DNS
         (Local cache)      (DNS over TLS)   (1.1.1.1:853)
```

**Web Traffic Flow:**
```
Device → OPNsense (NAT) → Internet → Website
         (Private IP → Public IP)
```

**VPN Access:**
```
Remote Device → WireGuard VPN → Full LAN Access
               (Encrypted tunnel)
```

## Implementation Phases

### Phase 1: DNS Configuration
Configure OPNsense Unbound DNS with domain-based hostnames and dual naming.

**Tasks:**
- [1.1 Verify Unbound DNS is Enabled](1.1%20Verify%20Unbound%20DNS%20is%20Enabled.md)
- [1.2 Configure Unbound DNS Settings](1.2%20Configure%20Unbound%20DNS%20Settings.md)
- [1.3 Configure DHCP to Use Unbound](1.3%20Configure%20DHCP%20to%20Use%20Unbound.md)
- [1.4 Configure Proxmox DNS](1.4%20Configure%20Proxmox%20DNS.md)
- [1.5 Set Hostname on Proxmox](1.5%20Set%20Hostname%20on%20Proxmox.md)
- [1.6 Set Hostname on OPNsense](1.6%20Set%20Hostname%20on%20OPNsense.md)
- [1.7 Configure Route 53 DNS Records](1.7%20Configure%20Route%2053%20DNS%20Records.md)
- [1.8 Update Proxmox Hostname with Domain](1.8%20Update%20Proxmox%20Hostname%20with%20Domain.md)
- [1.9 Add DNS Override for Proxmox (FQDN)](1.9%20Add%20DNS%20Override%20for%20Proxmox%20(FQDN).md)
- [1.10 Add DNS Override for OPNsense (FQDN)](1.10%20Add%20DNS%20Override%20for%20OPNsense%20(FQDN).md)
- [1.11 Configure SSH Client Config (Local Machine)](1.11%20Configure%20SSH%20Client%20Config%20(Local%20Machine).md)
- [1.12 Add DNS Overrides for VMs (As Needed)](1.12%20Add%20DNS%20Overrides%20for%20VMs%20(As%20Needed).md)

### Phase 2: WireGuard VPN Setup
Set up WireGuard VPN for secure remote access to the home network.

**Tasks:**
- [2.1 Install WireGuard Plugin](2.1%20Install%20WireGuard%20Plugin.md)
- [2.2 Configure WireGuard Server](2.2%20Configure%20WireGuard%20Server.md)
- [2.3 Create WireGuard Interface](2.3%20Create%20WireGuard%20Interface.md)
- [2.4 Configure WAN Firewall Rule (Allow WireGuard)](2.4%20Configure%20WAN%20Firewall%20Rule%20(Allow%20WireGuard).md)
- [2.5 Verify WAN Firewall Blocks Other Traffic](2.5%20Verify%20WAN%20Firewall%20Blocks%20Other%20Traffic.md)
- [2.6 Configure WireGuard Firewall Rules](2.6%20Configure%20WireGuard%20Firewall%20Rules.md)
- [2.7 Configure NAT for WireGuard](2.7%20Configure%20NAT%20for%20WireGuard.md)
- [2.8 Create WireGuard Endpoint](2.8%20Create%20WireGuard%20Endpoint.md)
- [2.9 Create First WireGuard Client](2.9%20Create%20First%20WireGuard%20Client.md)
- [2.10 Export and Import Client Configuration](2.10%20Export%20and%20Import%20Client%20Configuration.md)
- [2.11 Test VPN Connection](2.11%20Test%20VPN%20Connection.md)
- [2.12 Verify Services NOT Accessible Without VPN](2.12%20Verify%20Services%20NOT%20Accessible%20Without%20VPN.md)
- [2.13 Port Forwarding (If Behind NAT)](2.13%20Port%20Forwarding%20(If%20Behind%20NAT).md)

### Phase 3: TLS/SSL Certificate Management (Optional)
Set up TLS/SSL certificates for internal/VPN use only.

**Tasks:**
- [3.1 Choose TLS Solution](3.1%20Choose%20TLS%20Solution.md)
- [3.2 Install ACME Plugin (If Using Option A)](3.2%20Install%20ACME%20Plugin%20(If%20Using%20Option%20A).md)
- [3.3 Configure ACME Account (If Using Option A)](3.3%20Configure%20ACME%20Account%20(If%20Using%20Option%20A).md)
- [3.4 Create Certificate (If Using Option A)](3.4%20Create%20Certificate%20(If%20Using%20Option%20A).md)

## Prerequisites

- OPNsense running on `192.168.1.1` (hostname: `shire`)
- Proxmox running on `192.168.1.10` (hostname: `numenor`)
- Domain: `cuffney.com` (hosted in AWS Route 53)
- Access to OPNsense Web UI
- Access to Proxmox Web UI
- SSH access to both systems
- AWS Console access (for Route 53 configuration)

## Quick Start

1. **Read this README** to understand the architecture
2. **Complete tasks in order** - each task builds on previous ones
3. **Test each task** before moving to the next
4. **Follow the security model** - never expose services to public internet

## Task File Naming

Tasks are organized as individual markdown files named: `{Phase}.{Task} {Task Name}.md`

Example:
- `1.1 Verify Unbound DNS is Enabled.md`
- `2.4 Configure WAN Firewall Rule (Allow WireGuard).md`

Each task file contains:
- **Objective**: What you're trying to achieve
- **Steps**: Detailed step-by-step instructions
- **Test**: How to verify it works
- **Expected Result**: What success looks like

## Testing Checklist

After completing all tasks, verify:

- [ ] DNS resolution works: `nslookup numenor.cuffney.com`, `nslookup shire.cuffney.com`
- [ ] SSH works using FQDNs: `ssh jcuffney@numenor.cuffney.com`, `ssh jcuffney@shire.cuffney.com`
- [ ] VPN connects successfully from external network using `shire.cuffney.com`
- [ ] VPN clients can access LAN services (Proxmox, VMs, etc.)
- [ ] VPN clients can resolve FQDNs (numenor.cuffney.com, shire.cuffney.com, VMs)
- [ ] Services are NOT accessible from public internet (without VPN)
- [ ] Only WireGuard port (51820/UDP) is accessible from internet
- [ ] Route 53 records exist for all hosts (for external/VPN access)

## Troubleshooting

**DNS not resolving**:
- Check Unbound is enabled: `Services → Unbound DNS → General`
- Verify DNS override exists: `Services → Unbound DNS → Overrides`
- Test: `dig @192.168.1.1 numenor.cuffney.com`
- Verify Route 53 records exist (for external access)
- Check domain is set correctly: `System → Settings → General` (should be `cuffney.com`)

**SSH not working with FQDN**:
- Verify DNS resolution: `nslookup numenor.cuffney.com`
- Check SSH config: `~/.ssh/config`
- Test with IP: `ssh jcuffney@192.168.1.10`
- Verify hostname is set: `hostnamectl` (should show FQDN)

**VPN not connecting**:
- Check WireGuard status: `VPN → WireGuard → Status`
- Verify firewall rules allow port 51820
- Check port forwarding if behind NAT
- Verify `shire.cuffney.com` resolves to public IP (for endpoint)
- Review WireGuard logs: `VPN → WireGuard → Log File`

**Services accessible from internet**:
- Review WAN firewall rules
- Ensure only port 51820 is forwarded
- Test from mobile data to verify blocking

**Domain not resolving externally**:
- Verify Route 53 A records exist for all hosts
- Check TTL values (300 seconds recommended)
- Wait for DNS propagation (can take a few minutes)
- Test from external network: `nslookup shire.cuffney.com`

## Notes

- Complete tasks in order - each task builds on previous ones
- Test each task before moving to the next
- If a task fails, troubleshoot before continuing
- Keep notes of any customizations or deviations
- Backup OPNsense configuration after major changes
- Both descriptive and themed hostnames must be configured for every host
