---
title: Quick Start
nav_order: 1
parent: Getting Started
layout: default
---

# Quick Start

Get Pi Gateway running on your Raspberry Pi in 15 minutes.

## One-Command Installation (Recommended)

For a default installation with all features:

```bash
curl -sSL https://raw.githubusercontent.com/1mb-dev/pi-gateway/main/scripts/quick-install.sh | bash
```

This will:
- Install dependencies (openssh-server, wireguard, ufw, fail2ban)
- Configure SSH with key-based authentication
- Set up WireGuard VPN
- Enable firewall protection
- Apply system hardening

## After Installation

Once setup completes, you'll have:

- ✅ Secure SSH access with key-based authentication
- ✅ Personal VPN server for remote access
- ✅ Hardened firewall with fail2ban protection
- ✅ Dynamic DNS support
- ✅ System security hardening applied

## Next Steps

1. **Export SSH key** — Copy your SSH key to your local machine
2. **Configure Dynamic DNS** — Set up DuckDNS or No-IP
3. **Add VPN clients** — Create configurations for your devices
4. **Verify services** — Check that all services are running
5. **Review operations guide** — Learn daily management tasks

## Need Custom Setup?

For more control over installation, see [Manual Setup Guide]({{ site.baseurl }}/getting-started/setup/).

## Troubleshooting

- **Installation fails?** → See [Troubleshooting Guide]({{ site.baseurl }}/operations/troubleshooting/)
- **Can't SSH in?** → Check [Troubleshooting - SSH]({{ site.baseurl }}/operations/troubleshooting/#ssh-issues)
- **VPN not working?** → See [Troubleshooting - VPN]({{ site.baseurl }}/operations/troubleshooting/#vpn-issues)

## System Requirements

Before starting, ensure you have:
- Raspberry Pi 4 or newer
- 32GB+ MicroSD card
- Raspberry Pi OS installed
- Network connection (Ethernet recommended)
- Administrator access to your router

Learn more: [Full Setup Guide]({{ site.baseurl }}/getting-started/setup/) →
