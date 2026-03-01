---
title: Quick Install
nav_order: 1
parent: Example Guides
grand_parent: Getting Started
layout: default
---

# Quick Install

Get Pi Gateway running in under 15 minutes with one command.

## Prerequisites

- Raspberry Pi 4 or newer (Pi 5 recommended)
- Fresh Raspberry Pi OS installed
- Network connection (Ethernet recommended)
- SSH access to your Pi (initial setup only)

## One-Command Installation

```bash
curl -sSL https://raw.githubusercontent.com/1mb-dev/pi-gateway/main/scripts/quick-install.sh | bash
```

This will:
1. Install dependencies (openssh-server, wireguard, ufw, fail2ban)
2. Configure SSH with key-based authentication
3. Set up WireGuard VPN server
4. Enable firewall protection
5. Apply system security hardening

## What Happens During Install

```
Starting Pi Gateway Setup...
├─ Checking system requirements
├─ Installing dependencies
├─ Configuring SSH (hardening + key generation)
├─ Setting up WireGuard
├─ Configuring firewall (UFW)
├─ Enabling security updates
└─ Setup complete!

Your SSH key: ~/.ssh/id_rsa
Your VPN config: ~/.wireguard/
```

## After Installation

```bash
# Verify services are running
sudo systemctl status ssh          # SSH should be active
sudo systemctl status wg-quick@wg0  # WireGuard should be active
sudo ufw status                    # Firewall should be active/enabled

# Export your SSH key (save to your local machine)
cat ~/.ssh/id_rsa

# List your VPN server config
cat ~/.wireguard/wg0.conf
```

## Next Steps

1. **Back up SSH key** — Save it to a secure location on your local machine
2. **Configure Dynamic DNS** — See [Set Up Dynamic DNS](example-setup-dynamic-dns/)
3. **Add VPN Clients** — See [Add VPN Clients](example-add-vpn-clients/)
4. **Test SSH Access** — See [Configure SSH Access](example-configure-ssh/)

## Troubleshooting

**Installation fails at dependency check?**
```bash
# Check what's missing
./scripts/check-requirements.sh
```

**Services don't start?**
```bash
# Check logs
sudo journalctl -u ssh -n 20
sudo journalctl -u wg-quick@wg0 -n 20
```

**Can't SSH in?**
See [Configure SSH Access](example-configure-ssh/)

## Related

- Full guide: [Getting Started](../)
- Detailed setup: [Manual Setup Guide](setup/)
- Architecture: [How It Works](../guides/architecture/)
