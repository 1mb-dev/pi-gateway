# Security Best Practices

## Quick Security Checklist

- [ ] SSH key-based authentication only (disable password login)
- [ ] Custom SSH port configured (not default 22)
- [ ] Firewall enabled with minimal open ports
- [ ] fail2ban running and monitoring logs
- [ ] System packages updated regularly
- [ ] Strong VPN keys (WireGuard default is secure)
- [ ] Monitoring enabled for suspicious activity

## SSH Hardening

**Configured automatically by Pi Gateway:**
- Disable root login
- Disable password authentication
- Use ed25519 or RSA 4096-bit keys
- Custom port (default: 2222)
- fail2ban protection against brute force

**Manual verification:**
```bash
# Check SSH configuration
sudo sshd -T | grep -E 'passwordauthentication|permitrootlogin'

# Verify fail2ban status
sudo fail2ban-client status sshd
```

## System Hardening

**Applied by `system-hardening.sh`:**
- Kernel parameter hardening (sysctl)
- Network security settings
- Service hardening
- File system permissions

**Verify hardening:**
```bash
# Check kernel parameters
sudo sysctl net.ipv4.conf.all.rp_filter
sudo sysctl kernel.dmesg_restrict

# Review running services
systemctl list-units --type=service --state=running
```

## Firewall Configuration

**Default rules (UFW):**
- Deny all incoming by default
- Allow SSH on custom port
- Allow WireGuard VPN (51820/udp)
- Allow VNC if configured (5901/tcp)
- Rate limiting on SSH

**Check firewall status:**
```bash
sudo ufw status verbose
sudo ufw show raw
```

## VPN Security

**WireGuard best practices:**
- Unique keys per client
- Rotate keys periodically (90 days recommended)
- Limit VPN network access (not full tunnel by default)
- Monitor active connections

**Manage VPN clients:**
```bash
# List clients
./scripts/vpn-client-manager.sh list

# Remove compromised client
sudo ./scripts/vpn-client-manager.sh remove <client-name>

# Generate new client
sudo ./scripts/vpn-client-manager.sh add <new-client>
```

## Monitoring & Alerts

**Key logs to monitor:**
```bash
# SSH authentication attempts
sudo journalctl -u ssh --since today

# Firewall blocks
sudo tail -f /var/log/ufw.log

# fail2ban actions
sudo tail -f /var/log/fail2ban.log

# System authentication
sudo tail -f /var/log/auth.log
```

## Updates & Maintenance

**Keep system secure:**
```bash
# Update packages
sudo apt update && sudo apt upgrade -y

# Update Pi Gateway
cd /path/to/pi-gateway
git pull
make validate

# Check for security advisories
sudo apt list --upgradable
```

## Incident Response

**If compromised:**
1. Disconnect from network immediately
2. Change all SSH keys and VPN credentials
3. Review auth logs: `sudo grep -i 'accepted\|failed' /var/log/auth.log`
4. Rebuild system from clean Pi Gateway installation
5. Report incident (see [SECURITY.md](../SECURITY.md))

## Additional Hardening (Optional)

**For high-security environments:**
- Enable audit logging: `sudo apt install auditd`
- Use 2FA for SSH: `sudo apt install libpam-google-authenticator`
- Implement intrusion detection: `sudo apt install aide`
- Configure log forwarding to remote syslog server

## Security Resources

- [CIS Benchmark for Debian](https://www.cisecurity.org/benchmark/debian_linux)
- [SSH Hardening Guide](https://www.ssh.com/academy/ssh/sshd_config)
- [WireGuard Security](https://www.wireguard.com/formal-verification/)
- [fail2ban Documentation](https://fail2ban.readthedocs.io/)
