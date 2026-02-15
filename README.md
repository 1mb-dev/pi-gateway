# Pi Gateway

[![CI Status](https://github.com/1mb-dev/pi-gateway/workflows/Pi%20Gateway%20CI/badge.svg)](https://github.com/1mb-dev/pi-gateway/actions)
[![Release](https://img.shields.io/github/v/release/1mb-dev/pi-gateway)](https://github.com/1mb-dev/pi-gateway/releases)
[![License](https://img.shields.io/github/license/1mb-dev/pi-gateway)](LICENSE)
[![Tests](https://img.shields.io/badge/tests-40%20tests%20|%20100%25%20pass-green)](https://github.com/1mb-dev/pi-gateway/actions)

**Secure remote access gateway for Raspberry Pi. SSH + VPN setup in under 10 minutes.**

## Overview

Pi Gateway transforms your Raspberry Pi into a secure remote access gateway with hardened SSH, WireGuard VPN, and firewall protection. Simple, focused, and production-ready.

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
- 40 unit tests with 100% pass rate
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

## Core Components

- System hardening and security best practices
- SSH with key-based authentication
- WireGuard VPN for encrypted remote access
- Firewall protection (UFW + fail2ban)

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

### Getting Started
- [Quick Start Guide](docs/quick-start.md) - 15-minute setup guide
- [Complete Setup Guide](docs/setup-guide.md) - Detailed installation instructions
- [Deployment Guide](docs/deployment-guide.md) - Production deployment guide

### Daily Operations
- [Usage Guide](docs/usage.md) - How to use installed services
- [Troubleshooting Guide](docs/troubleshooting.md) - Common issues and solutions

### Advanced Topics
- [Extension Development](docs/extensions.md) - Creating custom extensions
- [Security Best Practices](docs/security.md) - Security hardening and compliance
- [Technical Architecture](docs/TECHNICAL_BLOG.md) - In-depth technical blog post
- [Release Notes](docs/RELEASE_NOTES.md) - Version history and features

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

## 🧪 Development & Testing

### ✅ Production Validation Status
**Pi Gateway v1.2.0 has passed comprehensive end-to-end testing and is APPROVED FOR PRODUCTION DEPLOYMENT.**

- ✅ **40/40 Unit Tests Passing** (100% pass rate)
- ✅ **Complete E2E Testing** (All major components validated)
- ✅ **Security Hardening Verified** (Comprehensive security validation)
- ✅ **Production Ready** (Docker-based Pi simulation testing)

### Testing Environment
```bash
# Quick dry-run tests (safe, no system changes)
make test-dry-run

# Complete unit test suite (40 tests)
make test-unit

# End-to-end testing with Pi simulation
./tests/docker/test-pi-setup.sh

# Comprehensive validation suite
./tests/docker/comprehensive-test.sh

# Docker integration testing
make test-docker              # Simple mode
make test-docker-systemd      # Systemd mode
```

### E2E Testing Framework
```bash
# Quick Pi Gateway validation
./tests/docker/quick-e2e-test.sh

# Full Docker-based Pi simulation
./tests/docker/e2e-test.sh --keep-container

# Simple setup testing
./tests/docker/test-pi-setup.sh
```

### Development Setup
```bash
# Set up development environment
make dev-setup

# Code quality checks
make lint
make format-check

# QEMU testing (hardware emulation)
make setup-qemu
make test-integration
```

### Available Testing Commands
```bash
make test-dry-run           # Safe dry-run testing
make test-unit              # BATS unit tests
make test-docker            # Docker integration tests
make test-all-integration   # Complete test suite
make docker-shell          # Interactive Docker container
make docker-cleanup         # Clean Docker environment
```

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