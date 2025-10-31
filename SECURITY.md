# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.2.x   | :white_check_mark: |
| 1.1.x   | :white_check_mark: |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in Pi Gateway, please report it responsibly.

### How to Report

**Do not** open a public GitHub issue for security vulnerabilities.

Instead, report security issues via:
- **Email:** Open an issue with title "Security: [Brief Description]" and we'll provide a secure communication channel
- **Private Disclosure:** Use GitHub's private vulnerability reporting (if enabled for this repository)

### What to Include

Please provide:
- Description of the vulnerability
- Steps to reproduce the issue
- Affected versions
- Potential impact assessment
- Any suggested fixes (optional)

### Response Timeline

- **Initial Response:** Within 48 hours
- **Status Update:** Within 7 days
- **Fix Timeline:** Depends on severity (critical issues prioritized)

### Security Best Practices

When using Pi Gateway:
1. Always run on a dedicated Raspberry Pi (not shared with untrusted services)
2. Keep system packages updated (`sudo apt update && sudo apt upgrade`)
3. Use strong SSH keys (ed25519 recommended)
4. Review firewall rules before exposing services
5. Regularly rotate VPN client keys
6. Monitor system logs for suspicious activity

## Security Features

Pi Gateway includes:
- SSH hardening with key-based authentication
- System security hardening (CIS baseline)
- Firewall configuration (UFW + fail2ban)
- WireGuard VPN with encrypted tunnels
- Audit logging for critical operations
- Automated security updates (when enabled)

For detailed security configuration, see [docs/security.md](docs/security.md).
