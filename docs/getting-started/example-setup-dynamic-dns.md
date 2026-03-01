---
title: Set Up Dynamic DNS
nav_order: 4
parent: Example Guides
grand_parent: Getting Started
layout: default
---

# Example 4: Set Up Dynamic DNS

Keep your Pi Gateway accessible even when your ISP changes your IP address.

## Why Dynamic DNS?

Your ISP assigns you a public IP address (like 203.0.113.45). Unfortunately:
- ISPs change your IP address periodically (every 24-90 days typically)
- When IP changes, your domain stops working
- Dynamic DNS automatically updates your domain when IP changes

**Solution:** Use a Dynamic DNS service (DuckDNS, No-IP, Dynu) to map your domain to your current IP.

## Supported Services

Pi Gateway supports:

- **DuckDNS** (recommended: simple, free)
- **No-IP** (free tier available, requires monthly refresh)
- **Custom** (advanced: manually update your DNS provider)

## Quick Setup: DuckDNS

### Step 1: Create DuckDNS Account

1. Go to https://www.duckdns.org/
2. Sign in with GitHub, Google, or Reddit (no separate account needed)
3. Choose a subdomain: `your-name.duckdns.org`
4. Click "Install" (token appears on the page)
5. Copy your **token** (keep this secret!)

### Step 2: Configure Pi Gateway for DuckDNS

During initial setup, you're asked for Dynamic DNS configuration:

```bash
# During: ./setup.sh
# When asked: "Set up Dynamic DNS? [y/N]:"
# Answer: y

# When asked: "Which service? (duckdns/noip/custom):"
# Answer: duckdns

# When asked: "DuckDNS domain (e.g., your-name.duckdns.org):"
# Answer: your-name.duckdns.org

# When asked: "DuckDNS token:"
# Answer: (paste your token)

# Setup completes and verifies
```

### Step 3: Verify It's Working

```bash
# SSH to Pi
ssh -i ~/.ssh/pi-gateway-key pi@your-name.duckdns.org

# Check that dynamic DNS client is running
sudo systemctl status duckdns
# Should show: active (running)

# Check IP was updated
sudo journalctl -u duckdns -n 20
# Look for: "IP updated successfully" or similar

# Verify your domain resolves to your Pi's IP
nslookup your-name.duckdns.org
# Should show your public IP (203.0.113.X)
```

### Step 4: Test Remote Access

```bash
# From a different network (mobile hotspot, work, etc.):
ssh -i ~/.ssh/pi-gateway-key pi@your-name.duckdns.org

# Should work instantly (or within 5 minutes after IP change)
```

## Setup: No-IP

### Step 1: Create No-IP Account

1. Go to https://www.noip.com/
2. Sign up for free account
3. Create a hostname: `your-name.ddns.net` or similar
4. Note your **username** and **password**

### Step 2: Install No-IP Client

```bash
# SSH to Pi
ssh -i ~/.ssh/pi-gateway-key pi@raspberrypi.local

# Install No-IP client
sudo apt-get update
sudo apt-get install noip2

# Configure with your No-IP credentials
sudo noip2 -C
# It will ask for:
# - username: (your No-IP email)
# - password: (your No-IP password)
# - hostname: (your-name.ddns.net)

# Start the service
sudo systemctl start noip2
sudo systemctl enable noip2

# Verify status
sudo systemctl status noip2
```

### Step 3: Verify It's Working

```bash
# Check IP was updated
sudo journalctl -u noip2 -n 20
# Look for: "IP Updated"

# Verify domain resolves
nslookup your-name.ddns.net
# Should show your public IP
```

### Step 4: Important: Monthly Refresh

No-IP free tier requires monthly refresh to prevent hostname expiration:

```bash
# The noip2 daemon handles this automatically
# It renews every 30 days

# But if you stop using it for 30+ days:
# - Login to noip.com
# - Click "Modify" next to your hostname
# - Click "Update Hostname"

# Or the daemon renews automatically if you restart:
sudo systemctl restart noip2
```

## Setup: Custom DNS Provider

If using your own domain (namecheap.com, godaddy.com, route53, etc.):

### Manual Update Script

Create a script to update your DNS:

```bash
# On Pi, create: /home/pi/update-dns.sh
#!/bin/bash

# Get your current public IP
IP=$(curl -s https://checkip.amazonaws.com)

# Update your DNS provider (example for Namecheap)
# Replace:
# - YOUR_DOMAIN with your domain (example.com)
# - YOUR_SUBDOMAIN with your subdomain (pi, gateway, etc.)
# - YOUR_DDNS_PASSWORD from Namecheap (not your account password)

curl "https://dynamicdns.park-your-domain.com/update?host=YOUR_SUBDOMAIN&domain=YOUR_DOMAIN&password=YOUR_DDNS_PASSWORD&ip=$IP"

# Log the update
echo "$(date): Updated YOUR_SUBDOMAIN.YOUR_DOMAIN to $IP" >> /var/log/dns-update.log
```

### Schedule It (Cron)

```bash
# Edit crontab
sudo crontab -e

# Add this line (update every 5 minutes):
*/5 * * * * /home/pi/update-dns.sh

# Save: Ctrl+X, Y, Enter

# Verify it runs
sudo journalctl -u cron
```

## Troubleshooting Dynamic DNS

### Domain Not Resolving

```bash
# 1. Check service is running
sudo systemctl status duckdns  # or noip2
# Should show: active (running)

# 2. Check IP was actually updated
sudo journalctl -u duckdns -n 50
# Look for: "Updated to 203.0.113.X"

# 3. Clear DNS cache and check again (macOS)
sudo dscacheutil -flushcache
nslookup your-domain.duckdns.org

# 3. Clear DNS cache (Linux)
sudo systemctl restart systemd-resolved
nslookup your-domain.duckdns.org

# 4. Verify your ISP IP is correct
curl -s https://checkip.amazonaws.com
# Compare this IP with what nslookup returns
```

### Service Not Running

```bash
# Check what went wrong
sudo journalctl -u duckdns -n 50 --no-pager
# Look for errors

# Restart the service
sudo systemctl restart duckdns

# If still fails:
# - Check token is correct (DuckDNS)
# - Check credentials are correct (No-IP)
# - Check network connectivity: ping google.com
```

### IP Changes Frequently (or Never)

```bash
# Check your actual public IP
curl https://checkip.amazonaws.com

# If IP keeps changing:
# - This is normal, but add retry logic to your script
# - Increase update interval in cron (every 1 minute instead of 5)

# If IP never changes:
# - Your router might be providing the same IP
# - Or you're behind a carrier NAT (ISP issue, not fixable)
# - Try: https://whatismyipaddress.com to verify your true public IP
```

### SSH Works Locally But Not Remotely

```bash
# 1. Verify domain resolves to correct IP
nslookup your-domain.duckdns.org

# 2. Verify port 22 is actually open to internet
# (Use: https://www.canyouseeme.org/ or similar port-check tool)
# Enter: your-domain.duckdns.org and port 22

# 3. If port shows as "closed":
#    - Check firewall allows port 22
sudo ufw status | grep 22

#    - Check router port forwarding (if using one)
#    - Check ISP isn't blocking port 22 (less common)

# 4. Verify SSH service is listening
sudo ss -tlnp | grep 22
# Should show: :22 LISTEN
```

## DNS Testing

### Test from Multiple Locations

```bash
# Google Public DNS:
nslookup your-domain.duckdns.org 8.8.8.8

# CloudFlare DNS:
nslookup your-domain.duckdns.org 1.1.1.1

# Your local Pi's DNS:
nslookup your-domain.duckdns.org localhost

# All should return your public IP
```

### Deep DNS Debugging

```bash
# Get all DNS records for your domain
dig your-domain.duckdns.org

# Expected output (simplified):
# ;; ANSWER SECTION:
# your-domain.duckdns.org. 60 IN A 203.0.113.45
#                                ^^ This should match your public IP
```

## Switching DNS Services

If you need to switch from DuckDNS to No-IP or vice versa:

### Option 1: Update Configuration (Simple)

```bash
# Edit the dynamic DNS config
sudo nano /etc/pi-gateway/duckdns.conf
# Or:
sudo nano /etc/pi-gateway/noip.conf

# Update settings and restart
sudo systemctl restart duckdns
# Or:
sudo systemctl restart noip2
```

### Option 2: Re-run Setup (Recommended)

```bash
# SSH to Pi
ssh -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org

# Run setup again
cd ~/pi-gateway
sudo ./setup.sh

# When asked about dynamic DNS, choose your new service
# Keep everything else the same
```

## Best Practices

### Security

```bash
# ✅ Good: Keep your DuckDNS token secret
# ✅ Good: Use firewall to restrict SSH (fail2ban does this)
# ✅ Good: Check domain resolves before assuming it's working

# ❌ Bad: Share your DuckDNS token in public (GitHub, forums)
# ❌ Bad: Post your domain publicly if you're running Pi Gateway
# ❌ Bad: Leave SSH port open without fail2ban protection
```

### Monitoring

```bash
# Periodically verify your domain still works
*/6 * * * * ssh -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org exit
# This cron job tests connectivity every 6 hours

# Or manually test monthly:
ssh -i ~/.ssh/pi-gateway-key pi@your-domain.duckdns.org
```

### Update Intervals

```bash
# DuckDNS: Updates as fast as you can request (~30 second minimum)
# No-IP: Updates every 30 minutes (client daemon)
# Custom: Set cron interval (5 minutes recommended)

# If your IP changes frequently and you need instant updates:
# Use a custom script that updates every 1-2 minutes
```

## FAQ

**Q: Can I use my own domain instead of DuckDNS?**
A: Yes, use the "Custom" option. You'll need to configure DDNS with your domain registrar (Namecheap, GoDaddy, etc.).

**Q: What if my IP doesn't change for weeks?**
A: That's fine. Dynamic DNS still works. Your domain will resolve to the same IP until it changes.

**Q: Can I use dynamic DNS without setting up SSH?**
A: Yes, they're independent. You can have dynamic DNS without SSH access.

**Q: Does my domain need to be public?**
A: No, it works with dynamic DNS subdomains (your-name.duckdns.org). You can make it unlisted to avoid bots scanning your IP.

**Q: What if ISP blocks port 22 (SSH)?**
A: You can configure SSH to run on port 443 (HTTPS) if needed, but this is less common. Check with your ISP.

## Next Steps

- [Configure SSH Access](example-configure-ssh/) — Now that you have a domain
- [Add VPN Clients](example-add-vpn-clients/) — VPN access through your domain
- [Troubleshooting Guide](example-troubleshooting/) — Fix common issues
- [Daily Operations Guide](../operations/daily-operations/) — Monitor your setup
