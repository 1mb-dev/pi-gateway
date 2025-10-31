# QEMU Pi Emulation Testing

Full Raspberry Pi hardware emulation for integration testing.

## Overview

QEMU test images are **not stored in git**. The `setup-pi-vm.sh` script downloads them on-demand (~2.3GB total).

**Git repository size:** ~17MB
**Working directory with QEMU:** ~2.3GB (downloaded locally only)

## Quick Start

```bash
# Download and setup QEMU environment (one-time, ~2.3GB download)
make setup-qemu

# Run integration tests
make test-integration
```

## Prerequisites

Install QEMU with ARM64 support:

```bash
# macOS
brew install qemu

# Ubuntu/Debian
sudo apt install qemu-system-arm

# Arch Linux
sudo pacman -S qemu-system-aarch64
```

## What Gets Downloaded

The setup script downloads these files on-demand:

| File | Size | Source |
|------|------|--------|
| Raspberry Pi OS Image | ~1.9GB | raspberrypi.org |
| Compressed Image | ~432MB | (deleted after extraction) |
| QEMU Kernel | ~5.2MB | qemu-rpi-kernel repo |
| Device Tree Binary | ~12KB | qemu-rpi-kernel repo |

**Total:** ~2.3GB after setup (compressed image is removed)

## Files Not in Git

These large files are gitignored and downloaded locally only:

```
tests/qemu/pi-gateway-test/
├── raspios-bookworm-arm64-lite.img   (1.9GB) - gitignored
├── 2024-07-04-raspios-*.img.xz       (432MB) - gitignored
├── kernel-qemu                        (5.2MB) - gitignored
└── versatile-pb.dtb                   (12KB)  - gitignored
```

## Usage

```bash
# Setup environment (downloads images on first run)
./tests/qemu/setup-pi-vm.sh

# Start VM
./tests/qemu/pi-gateway-test/run-pi-vm.sh

# SSH into VM
ssh pi@localhost -p 5022
# Default password: raspberry

# Restore clean VM snapshot
./tests/qemu/pi-gateway-test/restore-pi-vm.sh

# Destroy VM
./tests/qemu/pi-gateway-test/destroy-pi-vm.sh
```

## Cleaning Up

To remove QEMU files and reclaim disk space:

```bash
# Remove all downloaded images
rm -rf tests/qemu/pi-gateway-test/*.img*
rm -rf tests/qemu/pi-gateway-test/kernel-qemu

# Or destroy entire VM
./tests/qemu/pi-gateway-test/destroy-pi-vm.sh
```

Re-run `make setup-qemu` to download again when needed.

## CI/CD

Integration tests run only on `main` branch pushes to avoid unnecessary downloads in CI.

See `.github/workflows/ci.yml` for configuration.
