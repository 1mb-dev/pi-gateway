---
title: Troubleshooting Guide
nav_order: 5
parent: Example Guides
grand_parent: Getting Started
layout: default
---

# Example 5: Troubleshooting Guide

Common issues and solutions for Pi Gateway setup and operation.

## Installation Issues

### Installation Script Fails

**Error:** `./setup.sh: command not found` or permission denied

```bash
# Fix: Make script executable
chmod +x setup.sh
./setup.sh

# If that doesn't work, use bash explicitly
bash setup.sh
```

**Error:** `Checking system requirements... FAILED`

```bash
# Check what's missing
./scripts/check-requirements.sh

# Common failures:
# - Raspberry Pi OS not detected: Are you on a Pi?
# - Git not installed: sudo apt-get install git
# - Bash version < 4: Update Raspberry Pi OS

# Update everything and try again
sudo apt-get update && sudo apt-get upgrade -y
./setup.sh
```

**Error:** `openssh-server installation failed` or similar

```bash
# Likely: Package repositories are broken
# Fix:
sudo apt-get clean
sudo apt-get update
sudo apt-get install --fix-broken
sudo apt-get install openssh-server wireguard ufw fail2ban -y

# Then re-run setup:
./setup.sh
```

### Insufficient Disk Space

**Error:** `No space left on device`

```bash
# Check disk usage
df -h
# If / (root) is 100%:

# Clean up old packages
sudo apt-get autoremove
sudo apt-get clean

# Remove old log files
sudo journalctl --vacuum=100M

# Try setup again
./setup.sh
```

### Network Issues During Setup

**Error:** `Failed to download dependencies` or similar

```bash
# Verify network connectivity
ping google.com

# If no response:
# - Check Pi is connected to network (Ethernet or WiFi)
# - Check WiFi password if using wireless
# - Check router has internet

# If network is fine, try manual setup:
sudo apt-get update
sudo apt-get install openssh-server wireguard ufw fail2ban

# Then run setup:
./setup.sh
```

## SSH Issues

### Cannot SSH to Pi

**Symptom:** `ssh: connect to host ... port 22: Connection refused`

**Diagnosis:**
```bash
# Check SSH service is running (need local access)
ssh pi@raspberrypi.local
sudo systemctl status ssh
```

**Solution:**
```bash
# If not running:
sudo systemctl start ssh
sudo systemctl enable ssh

# Check SSH configuration syntax
sudo sshd -t
# If there are errors, fix them:
sudo nano /etc/ssh/sshd_config
# Then restart:
sudo systemctl restart ssh
```

### SSH Hangs/Timeout

**Symptom:** SSH command waits indefinitely, then times out

```bash
# Check connectivity to Pi
ping your-domain.duckdns.org

# Check firewall allows SSH
sudo ufw status | grep 22
# Should show: 22/tcp ALLOW

# Check SSH service is listening
sudo ss -tlnp | grep 22
# Should show: 0.0.0.0:22 LISTEN

# If not listening:
sudo systemctl restart ssh
```

### "Permission denied (publickey)"

**Symptom:** SSH rejects your key

**Diagnosis:**
```bash
# Run SSH with verbose output
ssh -vvv -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org
# Look for which key was offered and why it was rejected
```

**Solution:**
```bash
# Verify your key is in authorized_keys
# (On Pi, via local access or existing SSH)
cat ~/.ssh/authorized_keys
# Your public key should appear here

# If missing, add it:
echo "ssh-ed25519 AAAA..." >> ~/.ssh/authorized_keys

# Check key file permissions on your machine
ls -la ~/.ssh/pi-gateway-key
# Should be: -rw------- (600)
chmod 600 ~/.ssh/pi-gateway-key

# Try again
ssh -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org
```

### "Too many authentication failures"

**Symptom:** `Received disconnect from ... Too many authentication failures`

**Cause:** fail2ban blocked your IP after repeated failed attempts

```bash
# Solution: Wait 10 minutes for automatic unblock
# Or, if you have physical access:

# Check what's blocked
sudo fail2ban-client status sshd

# Unblock your IP (replace with your actual IP)
sudo fail2ban-client set sshd unbanip 203.0.113.5

# Verify it's unblocked
sudo fail2ban-client status sshd
```

### Cannot Copy Files (SCP) But SSH Works

**Symptom:** `ssh pi@...` works, but `scp` fails silently or hangs

```bash
# Solution: Add verbose output
scp -vvv -i ~/.ssh/pi-gateway-key myfile.txt pi@your-domain.duckdns.org:~/

# If it hangs, check:
# - Permission to write to /home/pi/
# - Disk space on Pi: df -h
# - SSH can transfer large files: try smaller file first
```

## VPN Issues

### VPN Clients Cannot Connect

**Symptom:** VPN app shows "Connecting..." then fails or times out

**Diagnosis:**
```bash
# Check WireGuard service is running
ssh -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org
sudo systemctl status wg-quick@wg0
# Should show: active (running)

# Check port is open to internet
# (Use: https://www.canyouseeme.org/)
# Enter: your-domain.duckdns.org and port 51820
# Should show: "Success"

# Check firewall allows the port
sudo ufw status | grep 51820
# Should show: 51820/udp ALLOW
```

**Solution:**
```bash
# If WireGuard not running:
sudo systemctl restart wg-quick@wg0

# If port 51820 not in firewall:
sudo ufw allow 51820/udp
sudo systemctl restart wg-quick@wg0

# Verify clients have correct config
# (Check you exported QR code / config correctly)
```

### VPN Connected But No Internet Access

**Symptom:** VPN shows "Connected", but can't browse web or ping home network

**Diagnosis:**
```bash
# Check VPN IP is correct
ip addr show
# Should show: 10.0.0.x (or similar)

# Try to ping Pi (should work)
ping 10.0.0.1

# Try to ping home network (should work)
ping 192.168.1.1

# Try to ping internet (might fail)
ping 8.8.8.8
```

**Solution:**
```bash
# Problem 1: Firewall blocking tunneled traffic
# Fix on Pi:
sudo ufw allow from 10.0.0.0/24

# Problem 2: IP forwarding disabled
# Check and fix on Pi:
cat /proc/sys/net/ipv4/ip_forward
# If output is 0, enable it:
sudo sysctl -w net.ipv4.ip_forward=1

# Problem 3: VPN client config is wrong
# Regenerate the config on Pi:
./scripts/vpn-client-manager.sh
# Select: 3) Regenerate config

# Re-import on your device
```

### VPN Client Keeps Disconnecting

**Symptom:** VPN connects, then disconnects after 5-30 minutes

**Cause:** Router or ISP limiting UDP traffic

```bash
# On your device:
# 1. Check if it's a specific network (home vs mobile vs work)
# 2. Try VPN on different WiFi → determines if router-specific

# On Pi (check for timeouts):
sudo journalctl -u wg-quick@wg0 -f
# Look for: "Removing peer" or timeout messages

# Solution: Increase keepalive interval
# On your VPN client config:
# Find: PersistentKeepalive = 0
# Change to: PersistentKeepalive = 25
# (This sends a keepalive packet every 25 seconds)

# Regenerate config on Pi with new setting
```

### "Cannot find IP address" or DHCP Issues

**Symptom:** VPN connects but no IP address assigned

```bash
# Check Pi has DHCP server for VPN
sudo wg show wg0
# Look for: allowed_ips = 10.0.0.x

# If blank, WireGuard is misconfigured
# Check config:
sudo cat /etc/wireguard/wg0.conf

# Restart WireGuard:
sudo systemctl restart wg-quick@wg0

# If still broken, regenerate:
./scripts/vpn-setup.sh
```

## Network & Firewall Issues

### Cannot Reach Pi Even With VPN

**Symptom:** VPN is connected and has an IP, but can't ping Pi

```bash
# Check firewall rules
sudo ufw status
# Should show rules allowing:
# - 22/tcp (SSH)
# - 51820/udp (VPN)
# - 10.0.0.0/24 (VPN subnet)

# If rules missing:
sudo ufw allow 22/tcp
sudo ufw allow 51820/udp
sudo ufw allow from 10.0.0.0/24

# Verify with:
sudo ufw status numbered
```

### Port Already in Use

**Symptom:** Setup fails with "Address already in use" or "Port 22 already in use"

```bash
# Check what's using the port
sudo ss -tlnp | grep :22
# Output shows what process is using port 22

# Solution 1: Stop conflicting service
sudo systemctl stop [conflicting-service]
sudo systemctl disable [conflicting-service]

# Solution 2: Change to different port
# Edit SSH config:
sudo nano /etc/ssh/sshd_config
# Change: Port 2222
# Save and restart:
sudo systemctl restart ssh
sudo ufw allow 2222/tcp
```

## Dynamic DNS Issues

### Domain Not Resolving

**Symptom:** `nslookup your-domain.duckdns.org` shows old IP or fails

**Diagnosis:**
```bash
# Check IP update service is running
sudo systemctl status duckdns
# or
sudo systemctl status noip2

# Check if it's running and healthy
sudo journalctl -u duckdns -n 20
# Look for: "IP updated" or errors
```

**Solution:**
```bash
# Restart the service
sudo systemctl restart duckdns
# or
sudo systemctl restart noip2

# Wait 5 minutes and check again
nslookup your-domain.duckdns.org

# Clear local DNS cache (macOS)
sudo dscacheutil -flushcache

# Clear local DNS cache (Linux)
sudo systemctl restart systemd-resolved

# Check again
nslookup your-domain.duckdns.org
```

### "Authentication failed" or Token/Credentials Invalid

**Symptom:** Dynamic DNS logs show authentication error

```bash
# DuckDNS: Verify your token
# 1. Go to https://www.duckdns.org/
# 2. Check your token (it's displayed on the home page)
# 3. Update config:
sudo nano /etc/pi-gateway/duckdns.conf
# Find: TOKEN=
# Update with correct token

# No-IP: Verify your credentials
# 1. Go to https://www.noip.com/
# 2. Verify username and password
# 3. Restart service:
sudo systemctl restart noip2
# 4. Check logs:
sudo journalctl -u noip2 -n 20
```

### ISP Changes IP But Domain Doesn't Update

**Symptom:** Domain is outdated (old IP), dynamic DNS should have updated it

```bash
# Check if Pi can reach the internet
ping google.com

# Check if service knows your actual public IP
curl https://checkip.amazonaws.com

# Restart the service
sudo systemctl restart duckdns
# or
sudo systemctl restart noip2

# Force manual update:
# For DuckDNS:
curl "https://www.duckdns.org/update?domains=YOUR_DOMAIN&token=YOUR_TOKEN"

# Check status
nslookup your-domain.duckdns.org

# If still wrong, check:
# - Dynamic DNS service is enabled
# - Credentials are correct
# - No firewall blocking outbound HTTPS (port 443)
```

## Performance Issues

### SSH/VPN Very Slow

**Symptom:** Everything works but is very slow

**Diagnosis:**
```bash
# Check network latency
ping your-domain.duckdns.org
# Look at "time=" value
# < 50ms: Good
# 50-200ms: Acceptable
# > 200ms: Slow (likely ISP or distance)

# Check Pi isn't overloaded
ssh -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org
top
# Look for high CPU or memory usage

# Check disk is not full
df -h
# All partitions should be < 85% full
```

**Solution:**
```bash
# Pi overloaded: Stop unnecessary services
sudo systemctl stop [service]
sudo systemctl disable [service]

# Network slow: Nothing you can do about ISP
# But you can optimize settings

# Disk full: Delete old files or logs
sudo journalctl --vacuum=100M
sudo apt-get autoclean
```

### High Latency on VPN

**Symptom:** VPN works but ping times are high (>200ms)

```bash
# This is usually normal if:
# - Your ISP has high latency (common on satellite internet)
# - You're far from where your ISP routes through
# - You're using WiFi instead of Ethernet

# Solution:
# 1. Use Ethernet (not WiFi) on Pi
# 2. Use 5GHz WiFi on your client (not 2.4GHz)
# 3. Reduce other network load
# 4. Check ISP latency: ping 8.8.8.8 (without VPN)
```

## Hangs & Freezes

### Pi Becomes Unresponsive

**Symptom:** SSH hangs, VPN stops working, nothing responds

**Diagnosis:**
```bash
# Try to ping it
ping your-domain.duckdns.org
# If no response, Pi might be:
# - Overheating (check LED status)
# - Out of disk space (df -h)
# - Out of memory (free -h)
# - Crashed
```

**Solution:**
```bash
# Reboot via physical power
# 1. Unplug Pi from power
# 2. Wait 10 seconds
# 3. Plug back in
# 4. Wait 30 seconds for boot

# Or if you have SSH access:
sudo reboot

# After reboot, verify services are running:
sudo systemctl status ssh
sudo systemctl status wg-quick@wg0
sudo ufw status
```

### Running Out of Disk Space

**Symptom:** Setup fails or services stop unexpectedly

```bash
# Check disk usage
df -h

# Identify what's taking space
du -sh /home/*
du -sh /var/log/*

# Clean up:
# 1. Remove old logs
sudo journalctl --vacuum=100M

# 2. Clean package cache
sudo apt-get clean
sudo apt-get autoclean

# 3. Remove old kernels
sudo apt-get autoremove

# 4. Check for large files
find /home -type f -size +100M -exec ls -lh {} \;

# After cleanup:
df -h
# Should have > 20% free space
```

## Getting Help

### Collecting Debug Information

When asking for help, provide:

```bash
# System info
cat /etc/os-release
uname -a

# Installation log (if setup failed)
journalctl -u setup --no-pager > setup-log.txt

# Service status
sudo systemctl status ssh > ssh-status.txt
sudo systemctl status wg-quick@wg0 > vpn-status.txt

# Network info (be careful not to expose IPs)
ip route show
netstat -tlnp | grep ssh
netstat -tlnp | grep 51820

# Recent errors
sudo journalctl -p err -n 100 > errors.txt

# Share these files in your GitHub issue, but:
# - Remove sensitive info (tokens, domains, public IPs)
# - Keep the error messages and patterns
```

### Common Messages to Look For

| Error | Meaning | Fix |
|-------|---------|-----|
| `Address already in use` | Port is taken | Use different port or stop conflicting service |
| `Permission denied` | Not authorized | Use sudo for system commands |
| `Connection refused` | Service not listening | Start the service |
| `Connection timeout` | Host unreachable or blocked | Check firewall, routing, network |
| `Host key verification failed` | First-time connection | Answer `yes` to accept key |
| `Device or resource busy` | File/device locked | Restart service or reboot |

## FAQ

**Q: I lost my SSH key. Can I regain access?**
A: If you have physical access to Pi (keyboard + monitor), you can reset SSH. Otherwise, no.

**Q: Can I recover if I disable firewall completely?**
A: Yes, if you remember the command: `sudo ufw enable`

**Q: What if I brick the Pi?**
A: Worst case, you reflash the SD card with fresh Raspberry Pi OS and re-run setup.sh

**Q: Should I regularly reboot my Pi?**
A: No, Pi Gateway is designed to run continuously. Only reboot if needed.

**Q: Can I run this on a Pi Zero?**
A: Technically yes, but performance will be limited (CPU, RAM). Not recommended for production.

## When to Ask for Help

Open an issue at: https://github.com/1mb-dev/pi-gateway/issues

Include:
1. Your Raspberry Pi model
2. What you were doing when it broke
3. Error messages (from logs)
4. What you've tried so far

Before opening an issue:
1. Check the [Troubleshooting Guide](https://github.com/1mb-dev/pi-gateway/docs/operations/troubleshooting.md) in docs
2. Search existing issues
3. Try the solutions in this guide

## Next Steps

- [Quick Install](example-quick-install) — Start from the beginning
- [Configure SSH](example-configure-ssh) — SSH-specific help
- [Dynamic DNS Setup](example-setup-dynamic-dns) — Domain-specific help
- [Daily Operations](../operations/daily-operations.md) — Ongoing management
