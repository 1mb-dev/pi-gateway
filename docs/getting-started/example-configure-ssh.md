---
title: Configure SSH Access
nav_order: 3
parent: Example Guides
grand_parent: Getting Started
layout: default
---

# Configure SSH Access

Set up and manage SSH keys for secure remote access to your Pi.

## SSH Key Setup

After installation, your Pi Gateway has SSH configured with key-based authentication and fail2ban protection.

### Export Your SSH Key (First Time)

During initial setup, Pi Gateway generates an SSH key. You need to save this to your local machine:

```bash
# SSH to Pi (using temporary password or local access)
ssh pi@raspberrypi.local

# Export the private key
cat ~/.ssh/id_rsa

# Copy the output and save to your local machine
# macOS/Linux:
nano ~/.ssh/pi-gateway-key
# Paste the key, then Ctrl+X, Y, Enter

# Windows (PowerShell):
# Paste into: C:\Users\YourUsername\.ssh\pi-gateway-key
```

Set correct permissions:

```bash
# macOS/Linux
chmod 600 ~/.ssh/pi-gateway-key

# Verify permissions
ls -la ~/.ssh/pi-gateway-key
# Should show: -rw------- (600)
```

### Test SSH Connection

```bash
# If using domain name (DuckDNS)
ssh -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org

# If using local IP (192.168.1.X)
ssh -i ~/.ssh/pi-gateway-key pi@192.168.1.X

# If using Pi's local hostname
ssh -i ~/.ssh/pi-gateway-key pi@raspberrypi.local

# Expected output (first time only)
# "The authenticity of host ... can't be established"
# Type: yes
# Then you're in!
```

## Managing Additional SSH Keys

### Add Another User's SSH Key

When someone else needs SSH access:

1. **Get their public key:**

```bash
# On their machine:
ssh-keygen -t ed25519 -f ~/.ssh/id_pi_gateway -C "user@machine"
# Press Enter twice (no passphrase)
# This creates: ~/.ssh/id_pi_gateway (private) and ~/.ssh/id_pi_gateway.pub (public)

# They send you their PUBLIC key:
cat ~/.ssh/id_pi_gateway.pub
```

2. **Add to authorized_keys on Pi:**

```bash
# On your Pi (via SSH)
echo "ssh-ed25519 AAAA... user@machine" >> ~/.ssh/authorized_keys

# Verify it was added
cat ~/.ssh/authorized_keys
```

3. **They can now SSH in:**

```bash
# On their machine:
ssh -i ~/.ssh/id_pi_gateway pi@your-domain.duckdns.org
```

### Revoke SSH Access for a User

```bash
# On your Pi
nano ~/.ssh/authorized_keys

# Find the line with their key and delete it
# Save: Ctrl+X, Y, Enter

# They can no longer SSH in (tested immediately)
```

## SSH Configuration

### View Current SSH Configuration

```bash
# See what's configured
cat /etc/ssh/sshd_config | grep -v "^#" | grep -v "^$"

# Key settings:
# - PasswordAuthentication no (only keys allowed)
# - PermitRootLogin no (root can't SSH)
# - Port 22 (standard port)
```

### Change SSH Port (Advanced)

If you want SSH on a non-standard port (not recommended for beginners):

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Find: #Port 22
# Change to: Port 2222

# Save and test
sudo sshd -t  # Check syntax
sudo systemctl restart ssh

# Update firewall
sudo ufw allow 2222/tcp

# Now connect with:
ssh -p 2222 -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org

# Don't forget to update Dynamic DNS config if using it
```

## Troubleshooting SSH Access

### "Permission denied (publickey)"

```bash
# 1. Verify you're using the correct key
ssh -vvv -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org
# Shows detailed debug output

# 2. Check key permissions on your machine
ls -la ~/.ssh/pi-gateway-key
# Should be: -rw------- (600)

# 3. Check authorized_keys on Pi has your public key
ssh -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org
cat ~/.ssh/authorized_keys
# Should contain your public key

# 4. If key is wrong, add the correct one
echo "ssh-ed25519 AAAA..." >> ~/.ssh/authorized_keys
```

### "Connection timeout"

```bash
# 1. Verify Pi is reachable
ping your-domain.duckdns.org

# 2. Check if SSH service is running (requires local access)
ssh pi@raspberrypi.local
sudo systemctl status ssh

# 3. Check firewall allows port 22
sudo ufw status | grep 22
# Should show: 22/tcp ALLOW

# 4. If firewall blocking, allow SSH:
sudo ufw allow 22/tcp
```

### "Too many authentication failures"

```bash
# Likely cause: fail2ban blocking your IP
# Wait 10 minutes for the block to expire
# OR request Pi admin to whitelist your IP

# To whitelist your IP on Pi:
sudo fail2ban-client set sshd unbanip YOUR_IP_ADDRESS

# To check fail2ban status:
sudo fail2ban-client status sshd
```

### "Host key verification failed"

```bash
# First time connecting to a new domain
# Type: yes
# to accept the host key

# If you keep getting this error:
# 1. Clear the old key
ssh-keygen -R your-domain.duckdns.org

# 2. Connect again (will ask to add key)
ssh -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org
```

## SSH Security Best Practices

### Protect Your Private Key

```bash
# ✅ Good: Key in ~/.ssh/ with 600 permissions
chmod 600 ~/.ssh/pi-gateway-key

# ✅ Good: Never share private key
# ❌ Bad: Sharing private key with others
# ❌ Bad: Key permissions readable by others (644, 755)

# Check if others can read your key:
ls -la ~/.ssh/pi-gateway-key
# If you see: -rw-r--r-- (644) — FIX IT!
chmod 600 ~/.ssh/pi-gateway-key
```

### Backup Your SSH Key

```bash
# macOS/Linux
# Create secure backup
mkdir ~/.ssh/backup
cp ~/.ssh/pi-gateway-key ~/.ssh/backup/
chmod 600 ~/.ssh/backup/pi-gateway-key

# Verify backup
cat ~/.ssh/backup/pi-gateway-key | head -1
# Should show: -----BEGIN OPENSSH PRIVATE KEY-----

# Store in password manager or encrypted external drive
```

### Add SSH Key with Passphrase (Optional)

For extra security, protect your SSH key with a passphrase:

```bash
# Generate new key with passphrase
ssh-keygen -t ed25519 -f ~/.ssh/pi-gateway-secure -C "my-pi-gateway"
# Enter passphrase when prompted (you'll type it each time you SSH)

# Use the new key
ssh -i ~/.ssh/pi-gateway-secure pi@your-domain.duckdns.org
# You'll be prompted for the passphrase
```

## SSH Tips & Tricks

### Create SSH Config for Easier Access

```bash
# Edit your SSH config
nano ~/.ssh/config

# Add:
Host pi-gateway
    HostName your-domain.duckdns.org
    User pi
    IdentityFile ~/.ssh/pi-gateway-key
    StrictHostKeyChecking accept-new

# Now just:
ssh pi-gateway
# No need to type: ssh -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org
```

### Copy Files via SSH (SCP)

```bash
# Download file from Pi
scp -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org:/home/pi/myfile.txt ~/Downloads/

# Upload file to Pi
scp -i ~/.ssh/pi-gateway-key ~/myfile.txt pi@your-domain.duckdns.org:/home/pi/

# Upload with custom SSH config
scp myfile.txt pi-gateway:~/
```

### SSH Tunnel (Port Forwarding)

Access a service running on your Pi through SSH tunnel:

```bash
# Forward local port 8080 to Pi's port 80 (web server)
ssh -i ~/.ssh/pi-gateway-key -L 8080:localhost:80 pi@your-domain.duckdns.org

# In another terminal, open:
curl http://localhost:8080
# You're accessing the Pi's web server!
```

### Keep SSH Connection Alive

```bash
# Edit SSH config
nano ~/.ssh/config

# Add to your pi-gateway host:
ServerAliveInterval 60
ServerAliveCountMax 5

# This prevents "Connection closed by remote host" after idle time
```

## Testing Your SSH Setup

### Verify SSH Works End-to-End

```bash
# 1. Connect
ssh -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org

# 2. Check you're on the Pi
hostname
# Should output: raspberrypi

# 3. Check SSH service is running
sudo systemctl status ssh
# Should show: active (running)

# 4. Check fail2ban status
sudo fail2ban-client status sshd

# 5. Check authorized_keys has your key
grep "ssh-ed25519" ~/.ssh/authorized_keys

# 6. Exit
exit
```

### Test from Another Machine

```bash
# Best test: Connect from a different device (phone, laptop, etc.)
# Use SSH client app (iPhone: Termius, Android: JuiceSSH)

# Enter:
# - Host: your-domain.duckdns.org
# - Port: 22
# - Username: pi
# - Key: pi-gateway-key (import the private key)

# If it works from multiple devices, your SSH is solid
```

## Next Steps

- [Add VPN Clients](example-add-vpn-clients/) — VPN access for other devices
- [Set Up Dynamic DNS](example-setup-dynamic-dns/) — Keep your hostname in sync
- [Troubleshooting Guide](example-troubleshooting/) — Solve common issues
- [Daily Operations Guide](../operations/daily-operations/) — Managing your Pi Gateway
