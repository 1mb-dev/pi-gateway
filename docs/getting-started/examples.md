---
title: Example Guides
nav_order: 4
parent: Getting Started
layout: default
---

# Example Guides

Problem-oriented examples for common Pi Gateway scenarios.

## Quick Start

1. **[Quick Install](example-quick-install)** — Install Pi Gateway in one line
2. **[Add VPN Clients](example-add-vpn-clients)** — Configure VPN for macOS, Windows, Linux, iOS, Android
3. **[Configure SSH Access](example-configure-ssh)** — Set up SSH keys and remote access
4. **[Set Up Dynamic DNS](example-setup-dynamic-dns)** — Keep your hostname in sync (DuckDNS, No-IP)
5. **[Troubleshooting Guide](example-troubleshooting)** — Solve common issues

## Use Case Scenarios

**Scenario: "I want secure SSH access to my Pi from anywhere"**
→ Follow: [Quick Start](example-quick-install) + [Configure SSH Access](example-configure-ssh)

**Scenario: "I want to access my entire home network remotely via VPN"**
→ Follow: [Quick Start](example-quick-install) + [Add VPN Clients](example-add-vpn-clients)

**Scenario: "I want both SSH and VPN with a custom domain"**
→ Follow: All guides in order

## Common Commands

```bash
# Add a new VPN client (e.g., for your laptop)
./scripts/vpn-client-manager.sh
# Then select: 1) Add new client

# Check system status
make status

# View logs
sudo journalctl -u ssh -f        # SSH logs
sudo journalctl -u wg-quick -f   # VPN logs
sudo ufw status                   # Firewall rules

# Test SSH connection
ssh -i ~/.ssh/pi-gateway-key user@your-domain.duckdns.org

# Export VPN client config for new device
cat ~/.wireguard/clients/my-client.conf
```

## Next Steps

After completing these examples:
1. Review [Daily Operations Guide](../operations/daily-operations)
2. Check [Troubleshooting Guide](../operations/troubleshooting) if issues arise
3. Read [Architecture Overview](../guides/architecture) to understand how it works
