---
layout: home
title: Pi Gateway Documentation
nav_order: 1
has_children: false
---

# Pi Gateway Documentation

Secure remote access gateway for Raspberry Pi. SSH + VPN setup in under 10 minutes.

## Quick Links

- **[Quick Start]({{ site.baseurl }}/getting-started/)** — Get running in 15 minutes
- **[Setup Guide]({{ site.baseurl }}/getting-started/setup/)** — Step-by-step installation
- **[Guides]({{ site.baseurl }}/guides/)** — Task-focused documentation
- **[Operations]({{ site.baseurl }}/operations/)** — Daily management and troubleshooting
- **[Development]({{ site.baseurl }}/development/)** — Contributing and extending

## What is Pi Gateway?

Pi Gateway transforms your Raspberry Pi into a hardened, secure remote access gateway with:

- **SSH hardening** — Key-based authentication, fail2ban protection
- **WireGuard VPN** — Encrypted remote access to home network
- **Firewall protection** — UFW with secure defaults
- **System hardening** — Security best practices applied

## Installation

```bash
curl -sSL https://raw.githubusercontent.com/1mb-dev/pi-gateway/main/scripts/quick-install.sh | bash
```

## Features

- ✅ 40/40 tests passing (100%)
- ✅ Security hardening verified
- ✅ Docker/QEMU tested
- ✅ Production ready

## Requirements

- Raspberry Pi 4/5 or compatible
- Raspberry Pi OS (Lite or Desktop)
- 32GB+ MicroSD card
- Administrator access to router
- SSH client for initial access

## Where to Start

**New to Pi Gateway?**
→ Start with [Quick Start Guide]({{ site.baseurl }}/getting-started/)

**Ready to dive deep?**
→ Read [System Architecture]({{ site.baseurl }}/guides/architecture/)

**Need help?**
→ Check [Troubleshooting]({{ site.baseurl }}/operations/troubleshooting/)

**Want to contribute?**
→ See [Development Guide]({{ site.baseurl }}/development/)

---

## Navigation

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 20px 0;">

<div style="border: 1px solid #e0e0e0; padding: 15px; border-radius: 5px;">
  <h3><a href="{{ site.baseurl }}/getting-started/">Getting Started</a></h3>
  <p>Installation, setup, and first steps</p>
</div>

<div style="border: 1px solid #e0e0e0; padding: 15px; border-radius: 5px;">
  <h3><a href="{{ site.baseurl }}/guides/">Guides</a></h3>
  <p>SSH, VPN, firewall, and architecture</p>
</div>

<div style="border: 1px solid #e0e0e0; padding: 15px; border-radius: 5px;">
  <h3><a href="{{ site.baseurl }}/operations/">Operations</a></h3>
  <p>Daily management, monitoring, troubleshooting</p>
</div>

<div style="border: 1px solid #e0e0e0; padding: 15px; border-radius: 5px;">
  <h3><a href="{{ site.baseurl }}/development/">Development</a></h3>
  <p>Contributing, testing, extending</p>
</div>

<div style="border: 1px solid #e0e0e0; padding: 15px; border-radius: 5px;">
  <h3><a href="{{ site.baseurl }}/reference/">Reference</a></h3>
  <p>Technical deep-dive, blog, FAQ</p>
</div>

</div>

---

**Latest Version:** v1.4.0
**License:** MIT
**GitHub:** [1mb-dev/pi-gateway](https://github.com/1mb-dev/pi-gateway)
