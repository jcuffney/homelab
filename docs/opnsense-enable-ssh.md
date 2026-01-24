# Enabling SSH Access on OPNsense

OPNsense has SSH disabled by default for security. This guide shows how to enable it.

## Enable SSH via Web UI

### Step 1: Access OPNsense Web Interface
1. Open browser and navigate to: `https://192.168.1.1`
2. Log in with your admin credentials

### Step 2: Navigate to SSH Settings
1. Go to: **System → Settings → Administration**
2. Scroll down to the **Secure Shell** section

### Step 3: Enable SSH
1. Check the box: **Enable Secure Shell**
2. Configure SSH settings:
   - **SSH Port**: `22` (default, or choose a different port)
   - **SSH Key Only**: ✅ (Recommended - requires SSH key, no password)
   - **SSH Password Authentication**: ⚠️ (Only enable if you need password auth)
   - **SSH Compression**: ✅ (Optional, can improve performance)
   - **SSH Host Key**: (Leave default or generate new)
3. Click **Save**

### Step 4: Configure Firewall Rule (If Needed)
SSH should work on LAN by default, but verify:

1. Navigate to: **Firewall → Rules → LAN**
2. Verify there's a rule allowing SSH (port 22) from LAN
3. If missing, create rule:
   - **Action**: `Pass`
   - **Interface**: `LAN`
   - **Protocol**: `TCP`
   - **Destination Port**: `22`
   - **Description**: `Allow SSH from LAN`
4. Click **Save** and **Apply Changes**

### Step 5: Verify SSH is Running
From your local machine, test SSH:

```bash
# Test SSH connection
ssh -v root@192.168.1.1

# Or test with your SSH key
ssh -i ~/.ssh/id_ed25519 root@192.168.1.1
```

## SSH Key Authentication Setup

### Option 1: Add SSH Key via Web UI (Recommended)

1. In OPNsense: **System → Settings → Administration**
2. Scroll to **Secure Shell** section
3. In **SSH Keys** field, paste your public key:
   ```
   ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPbbBr45lG6kPU6Ii7T4Td79CibnKkXMpaOCT5kJpZx josephcuffney@gmail.com
   ```
4. Check **SSH Key Only** to disable password authentication
5. Click **Save**

### Option 2: Add SSH Key via Command Line (If SSH is already enabled)

If you have console access or temporary SSH access:

```bash
# SSH into OPNsense
ssh root@192.168.1.1

# Add your public key to authorized_keys
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPbbBr45lG6kPU6Ii7T4Td79CibnKkXMpaOCT5kJpZx josephcuffney@gmail.com" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

## Troubleshooting

### SSH Connection Timeout

**Check if SSH service is running:**
1. In OPNsense: **System → Settings → Administration**
2. Verify **Enable Secure Shell** is checked
3. Check **Status → Services** to see if SSH service is running

**Check firewall rules:**
1. Navigate to: **Firewall → Rules → LAN**
2. Verify rule allows TCP port 22 from LAN network
3. Check **Firewall → Log Files** for blocked connections

**Test from OPNsense console:**
- Access OPNsense console directly (physical access or via web UI console)
- Run: `service sshd status` to check if SSH daemon is running
- Run: `service sshd start` if not running

### Permission Denied

**If using password authentication:**
- Ensure **SSH Password Authentication** is enabled in settings
- Try logging in with root password

**If using SSH key:**
- Verify your public key is added correctly in OPNsense settings
- Check key format (should be one line: `key-type key-data comment`)
- Verify **SSH Key Only** is checked if you want key-only auth
- Test key: `ssh -v -i ~/.ssh/id_ed25519 root@192.168.1.1`

### Connection Refused

**Check SSH port:**
- Verify SSH port in settings (default is 22)
- If using custom port, connect with: `ssh -p <port> root@192.168.1.1`

**Check if service is listening:**
From OPNsense console:
```bash
sockstat -l | grep ssh
# Should show sshd listening on port 22
```

## Security Best Practices

1. **Use SSH Key Only**: Enable **SSH Key Only** and disable password authentication
2. **Change Default Port**: Consider using a non-standard port (e.g., 2222) to reduce automated attacks
3. **Limit Access**: Use firewall rules to restrict SSH access to specific IPs if possible
4. **Keep OPNsense Updated**: Regularly update OPNsense for security patches
5. **Monitor Logs**: Check **System → Log Files → General** for SSH connection attempts

## Verify SSH Access

After enabling SSH, test from your local machine:

```bash
# Test basic connection
ssh root@192.168.1.1

# Test with verbose output (for debugging)
ssh -v root@192.168.1.1

# Test with specific key
ssh -i ~/.ssh/id_ed25519 root@192.168.1.1

# Test hostname resolution (after DNS is configured)
ssh root@opnsense
```

## Add to SSH Config

Once SSH is working, add to your `~/.ssh/config`:

```ssh-config
Host opnsense
    HostName opnsense
    User root
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    # Use IP as fallback if DNS fails
    # HostName 192.168.1.1
```

Then you can use: `ssh opnsense`

## Notes

- OPNsense uses FreeBSD, so some commands may differ from Linux
- Root user is the default admin user
- SSH access is typically only needed for advanced configuration
- Most OPNsense configuration can be done via web UI
- Consider disabling SSH when not needed for additional security
