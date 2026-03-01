# Pi Gateway

[![CI Status](https://github.com/1mb-dev/pi-gateway/workflows/Pi%20Gateway%20CI/badge.svg)](https://github.com/1mb-dev/pi-gateway/actions)
[![Release](https://img.shields.io/github/v/release/1mb-dev/pi-gateway)](https://github.com/1mb-dev/pi-gateway/releases)
[![License](https://img.shields.io/github/license/1mb-dev/pi-gateway)](LICENSE)

**Secure remote access gateway for Raspberry Pi. SSH + VPN setup in under 10 minutes.**

## Overview

Pi Gateway transforms your Raspberry Pi into a secure remote access gateway with hardened SSH, WireGuard VPN, and firewall protection. Simple, focused, and production-ready.

## When to Use This

Pi Gateway is for you if:
- You want SSH hardening, VPN, and firewall configured together as a single setup
- You prefer an opinionated, tested configuration over assembling pieces yourself
- You want dry-run mode to preview changes before they touch your system

Consider alternatives if:
- You only need a VPN — [PiVPN](https://pivpn.io/) is simpler for WireGuard-only setups
- You want fine-grained control over every setting — manual setup gives you that
- You're running on non-Raspberry Pi hardware — this project targets Pi OS specifically

## Quick Start

### One-Command Installation (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/1mb-dev/pi-gateway/main/scripts/quick-install.sh | bash
```

### Manual Installation
```bash
# Clone the repository
git clone https://github.com/1mb-dev/pi-gateway.git
cd pi-gateway

# Check system requirements
make check

# Run the setup (on your Raspberry Pi)
make setup
```

### Interactive Setup
```bash
curl -sSL https://raw.githubusercontent.com/1mb-dev/pi-gateway/main/scripts/quick-install.sh | bash -s -- --interactive
```

## Features

**Core Security:**
- SSH hardening with key-based authentication and fail2ban
- WireGuard VPN server with client management
- Firewall configuration (UFW) with secure defaults
- System security hardening

**Optional Components:**
- Remote desktop access (VNC)
- Dynamic DNS integration
- Custom port configuration

**Quality:**
- Dry-run mode for safe testing
- Docker and QEMU-based integration testing

## Requirements

### Hardware
- Raspberry Pi 500 (or compatible Pi 4/5)
- Raspberry Pi OS (Lite or Desktop)
- 32GB+ MicroSD card
- Reliable power supply & network connection

### Software
- Administrator access to home router
- Dynamic DNS provider account (DuckDNS, No-IP, etc.)
- SSH client for initial access

## Extensions

Advanced features moved to `extensions/` directory:
- Container orchestration (Docker/Podman)
- Web status dashboard
- Cloud backup integration
- Network optimization
- Automated maintenance
- System monitoring

See `extensions/README.md` for installation instructions.

## Documentation

Full documentation at [1mb-dev.github.io/pi-gateway](https://1mb-dev.github.io/pi-gateway/).

### Getting Started
- [Quick Start Guide](docs/getting-started/quick-start.md) - 15-minute setup guide
- [Setup Guide](docs/getting-started/setup.md) - Detailed installation instructions
- [Deployment Guide](docs/operations/production-deployment.md) - Production deployment

### Daily Operations
- [Daily Operations](docs/operations/daily-operations.md) - How to use installed services
- [Troubleshooting](docs/operations/troubleshooting.md) - Common issues and solutions

### Advanced Topics
- [Extension Development](docs/development/extensions.md) - Creating custom extensions
- [Security Updates](docs/operations/security-updates.md) - Security hardening and updates
- [Technical Architecture](docs/reference/technical-blog.md) - Technical deep dive
- [Release Notes](docs/reference/release-notes.md) - Version history

## Project Structure

```
pi-gateway/
├── setup.sh                      # Master setup script
├── scripts/                      # Modular service scripts
├── config/                       # Configuration templates
├── docs/                         # Documentation
├── extensions/                   # Optional future services
└── tests/                       # Validation scripts
```

## Development & Testing

```bash
make test-dry-run           # Safe dry-run testing (no system changes)
make test-unit              # BATS unit tests
make test-docker            # Docker integration tests
make test-all-integration   # Complete test suite
make lint                   # Code quality checks
```

For end-to-end testing with Pi simulation, see `tests/docker/`.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `make test` and `make validate`
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Support

For issues and feature requests, please visit the [GitHub Issues](https://github.com/1mb-dev/pi-gateway/issues) page.