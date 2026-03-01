---
title: Knowledge Transfer
nav_order: 1
parent: Reference
---

# Pi Gateway - Knowledge Transfer Guide

**Date:** 2026-03-01
**Project:** Pi Gateway (1mb-dev/pi-gateway)
**Status:** Production-Ready v1.2.0 | 40/40 Tests Passing
**Audience:** New contributors, team members, maintainers

---

## 1. Project Overview

**What Pi Gateway Does:**
Pi Gateway transforms a Raspberry Pi into a hardened, secure remote access gateway. It provides SSH and VPN access to your home network with production-grade security controls.

**Why It Exists:**
Homelab users and small businesses need secure remote access without the complexity of enterprise infrastructure. Pi Gateway makes this achievable in under 10 minutes while maintaining security best practices.

**Who Uses It:**
- Homelab enthusiasts wanting remote SSH access to their Pi
- Small businesses with modest infrastructure needs
- Developers testing VPN/SSH hardening configurations
- Teams learning security best practices

**Business Value:**
- Enables secure remote access without complex setup
- Reduces security incidents by hardening SSH/VPN from the start
- Lowers barrier to entry for infrastructure learning
- Community-driven knowledge sharing around security

**Ownership & Responsibilities:**
| Role | Owner | Responsibilities |
|------|-------|-----------------|
| Architecture & Design | Maintainers | Core design, extension system, security strategy |
| Code Quality | All Contributors | Testing, linting, documentation |
| Security | Maintainers + Community | Security audits, hardening validation, CVE response |
| Documentation | All Contributors | Guides, troubleshooting, examples |
| Releases | Maintainers | Version management, release notes, changelog |

**Key Links:**
- **Repository:** https://github.com/1mb-dev/pi-gateway
- **Documentation Hub:** `docs/` directory (11 comprehensive guides)
- **Issues:** https://github.com/1mb-dev/pi-gateway/issues
- **Contributing:** See `CONTRIBUTING.md` (to be created)
- **Security:** See `docs/security.md` for hardening details
- **Slack/Chat:** (Configure as needed)

---

## 2. Technical Architecture

### System Overview

```
┌──────────────────────────────────────────────────────────┐
│                    Home Network                          │
│                                                          │
│  ┌──────────────────────────────────────────────┐       │
│  │         Raspberry Pi (Pi Gateway)            │       │
│  │                                              │       │
│  │  ┌─────────────┐  ┌──────────┐  ┌────────┐ │       │
│  │  │ SSH Server  │  │WireGuard │  │Firewall│ │       │
│  │  │ (Hardened)  │  │  (VPN)   │  │ (UFW)  │ │       │
│  │  └─────────────┘  └──────────┘  └────────┘ │       │
│  │       │                │              │     │       │
│  │       ├─ Key-based    │ ├─ Clients  │ │    │       │
│  │       ├─ fail2ban     │ ├─ Tunnels  │ │    │       │
│  │       └─ Limits       │ └─ Routing  │ │    │       │
│  │                       │              │     │       │
│  │  ┌─────────────────────────────────────┐   │       │
│  │  │  System Hardening                   │   │       │
│  │  │  - Security updates                 │   │       │
│  │  │  - Secure defaults                  │   │       │
│  │  │  - Audit logging                    │   │       │
│  │  └─────────────────────────────────────┘   │       │
│  └──────────────────────────────────────────────┘       │
│           ▲                                      ▲       │
│           │ (Internet)                         │       │
└───────────┼──────────────────────────────────┬─┘       │
            │                                  │         │
            │ SSH Port (22)                    │         │
            │ VPN Port (51820)                 │         │
            │                                  │         │
      ┌─────┴──────┐                    ┌────┴──────┐   │
      │  Remote    │                    │ Dynamic   │   │
      │  User (PC) │                    │ DNS (DuckDNS) │
      └────────────┘                    └───────────┘   │
```

### Key Components

**1. SSH Service (ssh-setup.sh)**
- Key-based authentication (passwords disabled)
- fail2ban for brute-force protection
- Connection rate limiting
- Secure default configuration
- Purpose: Remote shell access with hardening

**2. WireGuard VPN (vpn-setup.sh)**
- Lightweight VPN protocol
- Client management system
- Encrypted tunnel to home network
- Scalable to many clients
- Purpose: Secure, encrypted remote access

**3. Firewall (firewall-setup.sh)**
- UFW (Uncomplicated Firewall) wrapper
- Default-deny policy
- Explicit allow rules for services
- Rate limiting and DDoS protection
- Purpose: Network security boundary

**4. System Hardening (security-hardening.sh, system-hardening.sh)**
- OS security best practices
- Automatic security updates
- Audit logging configuration
- Service hardening
- Purpose: Baseline security posture

**5. Extension System (extensions/)**
- Modular, optional features
- Backup, containers, monitoring, networking
- Not required for core functionality
- Can be added independently
- Purpose: Extensibility without bloat

### Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Runtime** | Bash/Shell | Lightweight, portable, standard on all Linux |
| **Testing** | BATS (Bash Automated Testing) | Shell script testing framework |
| **Automation** | Make | Task orchestration and CLI |
| **VCS** | Git | Version control, GitHub integration |
| **CI/CD** | GitHub Actions | Automated testing and validation |
| **Target OS** | Raspberry Pi OS | Debian-based Linux |
| **Container Testing** | Docker, QEMU | Development & validation environments |

### Data Flow: SSH Connection

```
1. Remote User
   └─> SSH Client (ssh user@example.duckdns.org)

2. Network
   └─> Pi Gateway (port 22, behind firewall)

3. SSH Service
   ├─ Check public key in ~/.ssh/authorized_keys
   ├─ fail2ban checks rate limits
   ├─ Grant access if authenticated
   └─> Shell session established

4. Session
   └─> User can execute commands, copy files, etc.

5. Cleanup
   └─> fail2ban logs auth events
```

### Data Flow: VPN Connection

```
1. Remote Client
   └─> WireGuard Client (connects to vpn.example.duckdns.org:51820)

2. Network
   └─> Pi Gateway WireGuard Interface

3. VPN Service
   ├─ Validate client public key
   ├─ Assign internal IP (10.0.0.x)
   ├─ Enable routing to home network
   └─> Encrypted tunnel established

4. Traffic
   └─> Client routes all traffic or selective IPs through tunnel

5. Cleanup
   └─> Client disconnects, route removed
```

### Extension Architecture

Extensions live in `extensions/` with a standard structure:

```
extensions/backup/
├── README.md          # What it does, how to use
├── install.sh         # Installation script
├── config/            # Configuration templates
└── scripts/           # Implementation

Key Pattern: Each extension is self-contained and installable independently
```

**Why Extensions?**
- Core stays focused on SSH + VPN + Firewall
- Users only install what they need
- Reduces complexity, maintenance burden
- Clear separation of concerns

---

## 3. Key Data Flows

### Setup Workflow

```
User runs: make setup
    │
    ├─> Pre-flight Check (pre-flight-check.sh)
    │   └─ Verify OS, architecture, hardware
    │
    ├─> Check Requirements (check-requirements.sh)
    │   └─ Verify dependencies available
    │
    ├─> Install Dependencies (install-dependencies.sh)
    │   └─ apt-get install openssh-server wireguard ufw fail2ban
    │
    ├─> System Hardening (system-hardening.sh)
    │   ├─ Disable root SSH login
    │   ├─ Enable security updates
    │   ├─ Configure audit logging
    │   └─ Apply kernel hardening
    │
    ├─> SSH Setup (ssh-setup.sh)
    │   ├─ Configure SSH daemon
    │   ├─ Generate or import SSH keys
    │   ├─ Configure fail2ban
    │   └─ Enable SSH service
    │
    ├─> VPN Setup (vpn-setup.sh)
    │   ├─ Generate WireGuard keys
    │   ├─ Create VPN interface
    │   ├─ Configure IP routing
    │   └─ Enable WireGuard service
    │
    ├─> Firewall Setup (firewall-setup.sh)
    │   ├─ Enable UFW
    │   ├─ Allow SSH (22)
    │   ├─ Allow VPN (51820)
    │   └─ Apply rate limiting
    │
    ├─> Optional: Dynamic DNS (ddns-setup.sh)
    │   └─ Configure DuckDNS / No-IP
    │
    └─> Completion
        └─ Print summary: SSH key, VPN config, next steps
```

### SSH Authentication Flow (Detailed)

```
Remote User
    │
    ├─ Has private key: ~/.ssh/pi-gateway-key
    │
    ├─> Initiates: ssh -i ~/.ssh/pi-gateway-key pi@gateway.duckdns.org
    │
    └─> Network Request
        └─> Pi Gateway SSH Service (port 22)
            │
            ├─ fail2ban Check
            │  ├─ Is IP rate-limited? (>3 failed logins in 10 min)
            │  └─ If yes, drop connection (temp block)
            │
            └─ SSH Authentication
               ├─ Client sends public key
               ├─ Server has: ~/.ssh/authorized_keys
               ├─ Keys match? YES → Continue
               │
               ├─ Session Established
               │  ├─ User can run commands
               │  ├─ All activity logged to syslog
               │  └─ fail2ban monitors for suspicious behavior
               │
               └─ Session Closed
                  └─ Audit log entry: "SSH login from IP X"
```

### VPN Client Management Flow

```
Administrator runs: vpn-client-manager.sh

Options:
  1) Add new client
  2) Revoke client
  3) List active clients
  4) Download client config
  5) Generate QR code

Example: Add New Client
    │
    ├─> Client Name: "laptop"
    │
    ├─> Generate Keys
    │   └─ wg genkey > client-laptop.key
    │
    ├─> Create VPN Config
    │   ├─ IP assignment: 10.0.0.2
    │   └─ Add to WireGuard interface
    │
    ├─> Create Client Config
    │   ├─ Client private key
    │   ├─ Server public key
    │   ├─ Server endpoint (duckdns.org:51820)
    │   └─ Allowed IPs (10.0.0.0/24, home network)
    │
    ├─> Export Config
    │   ├─ Save as: wg-client-laptop.conf
    │   └─ Or print QR code for phone import
    │
    └─> User Receives
        └─ Scans QR or imports config file
```

### Error Flow: Failed SSH Connection

```
Remote User attempts to SSH
    │
    └─> Incorrect password (3 times)
        │
        └─> fail2ban detects
            │
            ├─> Log entry: "Failed password for user X from IP Y"
            │
            ├─> fail2ban action
            │   └─ Drop all packets from IP Y for 10 minutes
            │
            └─> User sees
                └─ "Connection refused"

After 10 minutes: IP is unblocked automatically
```

---

## 4. Dependencies & Integration Points

### Upstream (Services Calling Pi Gateway)

These are the users/clients connecting to the services:

| Service | Protocol | Port | Client Type |
|---------|----------|------|-------------|
| SSH | SSH (over TLS) | 22 | Remote terminal, file transfer |
| VPN | WireGuard (UDP) | 51820 | VPN client app on PC/phone |
| Status (optional) | HTTP | 80/443 | Web dashboard, monitoring |

**Integration Pattern:**
- Clients initiate connections outbound
- Pi Gateway listens and accepts
- No inbound API dependencies (clean design)

### Downstream (External Services)

Pi Gateway depends on these external services:

| Service | Purpose | Criticality | Fallback |
|---------|---------|------------|----------|
| **Dynamic DNS** | Keep hostname in sync as ISP IP changes | High | Manual IP tracking |
| **Package Repos** | apt-get dependencies (openssh, wireguard, ufw) | High | Pre-installed Pi OS |
| **NTP (Time Sync)** | Keep system clock accurate | Medium | ~1 hour drift acceptable |
| **GitHub** | Installation scripts from public repo | Medium | Local copy fallback |

### Third-Party Integrations

| Integration | Purpose | Optional | How It Works |
|-------------|---------|----------|------------|
| **DuckDNS** | Free dynamic DNS | Optional | Cron job updates every 5 min |
| **No-IP** | Alternative dynamic DNS | Optional | Cron job updates every 5 min |
| **GitHub Releases** | Version tracking, announcements | Optional | Manual check, RSS feed |

### Resilience & Timeouts

**Network Timeouts:**
- SSH: 120s idle timeout (configurable)
- VPN: 3min check interval for client connectivity
- DNS updates: 5min (acceptable for dynamic DNS)

**Retry Logic:**
- DNS updates: 3 retries with 1min backoff
- Package installs: 3 retries on transient failures
- No exponential backoff (not needed for homelab)

**Circuit Breaker:**
- If dynamic DNS updates fail 10 times, alert admin
- If security updates fail, system continues (manual later)
- No "fail open" pattern (security-first design)

### Caching

- **SSH keys:** In-memory (never cached to disk except .ssh/)
- **VPN client list:** In-memory during WireGuard operation
- **System config:** File-based (reload on each operation for safety)

---

## 5. Development & Local Setup

### Prerequisites

**Hardware:**
- Any x86_64 or ARM machine for local testing
- 2GB+ RAM for testing
- 1GB disk space for code + tests

**Software:**
```bash
# macOS
brew install shellcheck bats-core git make

# Linux (Ubuntu/Debian)
sudo apt-get install shellcheck bats git make

# Windows
# Install WSL2 or use Docker Desktop, then follow Linux steps
```

### Step-by-Step Setup

#### 1. Clone Repository

```bash
git clone https://github.com/1mb-dev/pi-gateway.git
cd pi-gateway
```

#### 2. Verify Environment

```bash
# Check that required tools are installed
make check-tools

# Output should show:
#   ✓ git found
#   ✓ make found
#   ✓ shellcheck found
#   ✓ bats found
```

#### 3. Run Tests (Verify Baseline)

```bash
# Quick smoke test (linting only, no execution)
make validate

# Full unit test suite (should pass all 40 tests)
make test

# Docker-based E2E test (requires Docker)
./tests/docker/quick-e2e-test.sh
```

### Directory Layout for Development

```
pi-gateway/
├── setup.sh                    # Master setup script (entry point)
├── scripts/
│   ├── common.sh              # Shared utilities (ALWAYS source this first)
│   ├── ssh-setup.sh           # SSH hardening
│   ├── vpn-setup.sh           # VPN configuration
│   ├── firewall-setup.sh      # Firewall rules
│   ├── system-hardening.sh    # OS hardening
│   ├── security-hardening.sh  # Additional security
│   ├── pi-gateway-cli.sh      # Interactive CLI
│   └── ... (other scripts)
├── config/                     # Configuration templates
│   ├── ssh_config             # SSH daemon config template
│   ├── wireguard.conf         # VPN config template
│   └── ... (other configs)
├── docs/                       # Documentation
│   ├── quick-start.md
│   ├── setup-guide.md
│   ├── usage.md
│   └── ... (other guides)
├── extensions/                 # Optional modules
│   ├── backup/
│   ├── containers/
│   ├── monitoring/
│   └── ... (other extensions)
└── tests/                      # Test suite
    ├── unit/                   # BATS unit tests
    ├── integration/            # Integration tests
    ├── docker/                 # Docker-based E2E
    └── mocks/                  # Test fixtures
```

### Common Development Tasks

**Run Tests:**
```bash
make test              # All tests
make test-unit         # Unit tests only
make lint              # Code quality checks
make format-check      # Formatting check
```

**Testing a Script:**
```bash
# Manual testing (safe, read-only)
./scripts/check-requirements.sh

# With debug output
bash -x ./scripts/check-requirements.sh

# Using test fixtures
./tests/unit/check-requirements.bats
```

**Adding a New Script:**
1. Create `scripts/new-feature.sh`
2. Follow naming convention: `verb-noun.sh`
3. Source `scripts/common.sh` at top
4. Add unit tests in `tests/unit/new-feature.bats`
5. Run `make lint` to verify
6. Test locally before pushing

**Modifying Configuration:**
1. Edit template in `config/`
2. Test with: `./scripts/check-requirements.sh --dry-run`
3. Run full test suite: `make test`
4. Document changes in PR

### Development Workflows

#### Workflow 1: Bug Fix

```bash
# 1. Create feature branch
git checkout -b fix/issue-123-ssh-timeout

# 2. Locate the bug (usually in scripts/)
grep -n "timeout" scripts/ssh-setup.sh

# 3. Make fix
nano scripts/ssh-setup.sh  # Edit the problematic line

# 4. Test locally
./scripts/check-requirements.sh --dry-run
make test

# 5. Commit and push
git add scripts/ssh-setup.sh
git commit -m "fix: increase SSH timeout to handle slow networks"
git push origin fix/issue-123-ssh-timeout

# 6. Create PR on GitHub
```

#### Workflow 2: New Feature (Extension)

```bash
# 1. Create extension directory
mkdir extensions/my-feature
cd extensions/my-feature

# 2. Create structure
touch README.md install.sh

# 3. Write installation script
# - Source common.sh
# - Follow existing patterns
# - Add tests

# 4. Create unit tests
# tests/unit/extensions/my-feature.bats

# 5. Test thoroughly
make test

# 6. Submit PR with:
# - Feature implementation
# - Tests
# - Documentation
```

#### Workflow 3: Documentation

```bash
# 1. Create or edit doc
nano docs/new-guide.md

# 2. Link from README.md
# - Add entry to docs section

# 3. Build and test
make build-docs  # (if documentation build exists)

# 4. Commit and push
git add docs/new-guide.md README.md
git commit -m "docs: add guide for new feature"
git push origin docs/new-guide
```

---

## 6. Testing Strategy

### Test Framework: BATS (Bash Automated Testing System)

Why BATS?
- Tests are bash scripts (no special syntax)
- Runs shell scripts in isolated environment
- Mocks system calls for safety
- Integration tests can use real Pi simulation

### Test Structure

```
tests/
├── unit/                          # Unit tests (isolated, fast)
│   ├── check-requirements.bats     # OS/hardware validation
│   ├── install-dependencies.bats   # Dependency checking
│   ├── system-hardening.bats       # Security settings
│   └── integration/
│       └── pi-gateway-integration.bats  # Full flow
│
└── mocks/                         # Test fixtures
    ├── common.sh                  # Mock utilities
    ├── hardware.sh                # Hardware simulation
    ├── network.sh                 # Network simulation
    └── system.sh                  # OS simulation
```

### Test Categories

#### Unit Tests (Fast, Isolated)

**What:** Test individual script functions
**How:** Mock system calls, no actual changes
**Speed:** <1 second per test
**Coverage Target:** 80% (critical paths 100%)
**Location:** `tests/unit/*.bats`

Example: Testing SSH hardening
```bash
# Test: Verify SSH key-based auth is enforced
@test "SSH disables password authentication" {
  # Mock: Simulate /etc/ssh/sshd_config
  run grep "PasswordAuthentication no" config/ssh_config
  [ "$status" -eq 0 ]
}
```

#### Integration Tests (Realistic, Slower)

**What:** Test component interactions
**How:** Use real Pi simulation (Docker containers)
**Speed:** 5-30 seconds per test
**Coverage Target:** Happy path + key error cases
**Location:** `tests/integration/*.bats`

Example: Testing full SSH + Firewall
```bash
# Test: SSH works when firewall allows port 22
@test "SSH access granted when firewall allows port 22" {
  # Setup: Mock firewall allowing SSH
  # Action: Try SSH connection
  # Verify: Connection succeeds
}
```

#### E2E Tests (Real Environment)

**What:** Test on actual Raspberry Pi or Pi simulation
**How:** Docker container running Raspberry Pi OS
**Speed:** 2-10 minutes per test
**Coverage Target:** End-to-end workflows
**Location:** `tests/docker/*.sh`

Example: Setup and SSH

```bash
# Full workflow test
1. Start Docker container (Raspberry Pi OS)
2. Copy setup scripts inside
3. Run: make setup
4. Verify: SSH service running
5. Test: Remote SSH connection
6. Cleanup: Stop container
```

### Running Tests

**Quick Validation (5 seconds):**
```bash
make validate
# Runs shellcheck only (linting)
```

**Unit Tests (30 seconds):**
```bash
make test-unit
# Runs BATS unit tests, no system changes
```

**All Tests (2-5 minutes):**
```bash
make test
# Runs unit + integration + Docker E2E
```

**Specific Test:**
```bash
bats tests/unit/check-requirements.bats
# Run just one test file
```

### Test Data & Fixtures

**Mock Hardware (tests/mocks/hardware.sh):**
```bash
# Simulates Raspberry Pi hardware
mock_hardware_model() {
  echo "Raspberry Pi 4 Model B"
}
```

**Mock Network (tests/mocks/network.sh):**
```bash
# Simulates network interface
mock_network_interface() {
  echo "eth0"
}
```

**Seed Data (tests/seeds/):**
```bash
# Pre-made configs for testing
- ssh_config.test
- wireguard.test
- ufw.test
```

### CI/CD Pipeline

```
GitHub Push
    │
    ├─ Shellcheck Validation (2 min)
    │   └─ Find syntax errors, style issues
    │
    ├─ Unit Tests (1 min)
    │   └─ 40 tests, isolated execution
    │
    ├─ Docker Build (2 min)
    │   └─ Build Docker image for testing
    │
    ├─ Docker E2E Test (5 min)
    │   └─ Full setup in container
    │
    └─ Results
        ├─ ✅ All pass → PR reviewable
        └─ ❌ Any fail → Block merge until fixed
```

### Quality Gates

Before merging to main:
- ✅ All linting passes (no shellcheck warnings)
- ✅ All unit tests pass (40/40)
- ✅ Docker E2E test completes successfully
- ✅ Code review approval
- ✅ Security review (if touching hardening)

---

## 7. Known Issues & Gotchas

### Performance Gotchas

**1. DNS Lookup Delays**
- Issue: Dynamic DNS updates may have 1-2min latency
- Impact: After setup, may take a few minutes for DNS to propagate
- Mitigation: Document in quick-start guide
- Workaround: Use IP address directly until DNS updates

**2. fail2ban Learning Curve**
- Issue: If too aggressive, locks out legitimate users
- Impact: SSH becomes unreachable
- Mitigation: Conservative defaults (5 attempts, 600s timeout)
- Workaround: Physical access to Pi to reset fail2ban

### Non-Obvious Behaviors

**1. SSH Key Passphrases**
- SSH keys can have passphrases for extra security
- BUT: Pi Gateway setup assumes no passphrase (auto-login)
- Solution: Migrate to passphrase-protected keys after initial setup
- Warning: Document this limitation

**2. WireGuard Routing**
- By default, VPN tunnels all traffic (10.0.0.0/24 + home network)
- Some ISPs block outbound VPN traffic
- Mitigation: Document troubleshooting steps
- Workaround: Configure split tunneling (selective routing)

**3. Firewall Defaults**
- UFW defaults to "DENY all inbound"
- This is secure but may block unexpected traffic
- Solution: Document required ports and rationale
- Common mistake: Forgetting to allow port 22 before enabling UFW

### Bugs & Limitations

#### Known Bug: SC2116 Linting Warnings

**Status:** Low priority (style issue, no functional impact)
**Location:** `scripts/pi-gateway-cli.sh` (lines 472, 524, 531, 537)
**Issue:** Useless echo in read command
```bash
# Current (warns):
read -r -p "$(echo "text")" var

# Should be:
read -r -p "text" var
```
**Fix Priority:** Nice-to-have (cosmetic)
**Timeline:** Next release

#### Known Limitation: One-Command Installation

**Status:** Works for standard Raspberry Pi OS
**Limitation:** May fail on heavily customized systems
**Workaround:** Manual setup with make commands
**Mitigation:** Document required prerequisites

#### Known Limitation: Hardware Detection

**Status:** Works for Pi 3/4/5
**Limitation:** May not detect Pi Zero or older Pi 1
**Workaround:** Force bypass with env var
**Mitigation:** Add explicit hardware support

### Technical Debt

**Priority: Medium**

1. **Consolidate Hardening Scripts**
   - Current: `security-hardening.sh` + `system-hardening.sh` (overlap)
   - Better: Single unified hardening script
   - Effort: 2 hours
   - Impact: Simpler maintenance, clearer logic

2. **Improve Error Messages**
   - Current: Generic failures ("ssh-setup failed")
   - Better: Specific errors ("SSH key generation failed: permission denied")
   - Effort: 3-4 hours
   - Impact: Faster troubleshooting for users

3. **Add Dry-Run for All Scripts**
   - Current: Only some scripts have --dry-run
   - Better: All scripts support preview mode
   - Effort: 4-5 hours
   - Impact: Users can test safely before committing

### Mistakes Previous Developers Made (So You Don't)

1. **"I made an SSH config change without testing fail2ban interaction"**
   - Lesson: Test SSH + fail2ban together (not in isolation)
   - Action: Always run `make test-integration` before pushing SSH changes

2. **"I assumed all Raspberry Pi models have the same hardware"**
   - Lesson: Pi Zero, Pi 1, Pi 4 have different capabilities
   - Action: Test on multiple hardware or document limitations

3. **"I didn't account for slow network installs"**
   - Lesson: Package installs can timeout on slow connections
   - Action: Always set timeouts and retries
   - Example: `apt-get install --timeout=300 wireguard`

4. **"I updated config templates without updating the docs"**
   - Lesson: Template changes need doc updates
   - Action: Create issue: "doc: update SSH config guide with new options"

5. **"I tested on my machine but not on real Pi"**
   - Lesson: Development machine often differs from target
   - Action: Use Docker/QEMU to simulate Pi before pushing

---

## 8. Monitoring & Observability

### Key Metrics to Monitor

#### SSH Service Health

```bash
# Check SSH is listening
sudo ss -tlnp | grep :22

# Check fail2ban status
sudo fail2ban-client status sshd

# Check authentication logs
sudo grep "sshd" /var/log/auth.log | tail -20
```

**What to Watch For:**
- SSH service not listening (usually won't start due to config error)
- fail2ban throwing too many blocks (indicates brute-force or misconfiguration)
- Authentication errors (permission issues, key format problems)

**Alert Conditions:**
- SSH service down → Page on-call
- fail2ban blocking legitimate IPs > 5 times → Warn (review config)
- Auth errors increasing → Investigate (possible compromise attempt)

#### WireGuard VPN Health

```bash
# Check WireGuard interface
ip link show wg0

# Check active connections
sudo wg show wg0

# Check traffic
wg show wg0 transfer
```

**What to Watch For:**
- Interface not up (config error or startup failure)
- No client connections (users can't access)
- Unusual data transfer (possible data exfiltration)

**Alert Conditions:**
- Interface down → Page on-call
- Zero successful connections after 1 week → Warn (check if users know)
- Sudden traffic spike → Investigate (possible abuse)

#### Firewall Health

```bash
# Check UFW status
sudo ufw status

# Check blocked packets
sudo iptables -L -n -v

# Check rate limiting
sudo tc qdisc show
```

**What to Watch For:**
- UFW disabled accidentally → Critical
- Rules not as expected (extra open ports) → Security issue
- Rate limiting not applied → DoS vulnerability

**Alert Conditions:**
- UFW disabled → Page on-call immediately
- Unexpected port open → Page on-call immediately
- Rule changes detected → Warn + audit log

### Log Locations

**SSH Logs:**
```bash
/var/log/auth.log              # Authentication attempts
/var/log/syslog                # SSH startup/shutdown messages
journalctl -u ssh              # systemd journal (modern systems)
```

**VPN Logs:**
```bash
journalctl -u wg-quick@wg0     # WireGuard startup
dmesg | grep wireguard         # Kernel module logs
sudo wg show                    # Real-time stats
```

**Firewall Logs:**
```bash
sudo iptables -L -v            # Current rules
sudo ufw status verbose         # Detailed UFW rules
journalctl -u ufw              # UFW service logs
```

**System Logs:**
```bash
/var/log/syslog                # General system
/var/log/apt/                  # Package management
journalctl                     # systemd all
```

### Important Log Patterns

**SSH Pattern: Successful Login**
```
sshd[1234]: Accepted publickey for user from 203.0.113.5 port 54321
```
→ Normal, log it for audit trail

**SSH Pattern: Failed Login**
```
sshd[1234]: Failed password for user from 203.0.113.5 port 54321
```
→ Expected after 3+ attempts, fail2ban will block

**SSH Pattern: Connection from Unknown Key**
```
sshd[1234]: Invalid user guest from 203.0.113.5
```
→ Security concern, investigate source IP

**VPN Pattern: Client Connect**
```
[peer "Laptop"] Handshake successful, 1.23 seconds ago
```
→ Normal, client is connected

**VPN Pattern: Client Disconnect**
```
[peer "Laptop"] Last handshake now 5 minutes, 23 seconds ago
```
→ Client disconnected or network issue

**Firewall Pattern: Rate Limit Hit**
```
UFW BLOCK IN=eth0 OUT= MAC=... SRC=203.0.113.5 DST=192.168.1.1 PROTO=TCP SPT=54321 DPT=22
```
→ Someone trying to brute-force SSH, fail2ban will handle

### Debugging Tips

**SSH Won't Start:**
```bash
# 1. Check syntax
sudo sshd -t

# 2. Look for recent config changes
git log --oneline config/ssh_config

# 3. Check permissions
ls -la /etc/ssh/sshd_config
sudo systemctl restart sshd
```

**VPN Clients Can't Connect:**
```bash
# 1. Check interface is up
ip link show wg0

# 2. Check server public key is correct
sudo wg show wg0 public-key

# 3. Verify port is open
sudo ss -tlnp | grep 51820

# 4. Check firewall isn't blocking
sudo ufw status | grep 51820
```

**Firewall Blocks Everything:**
```bash
# 1. Check it's not in deny-all mode
sudo ufw status

# 2. Allow SSH if locked out
sudo ufw allow 22

# 3. Check rules are correct
sudo ufw status numbered

# 4. If misconfigured, reset carefully
sudo ufw reset  # WARNING: Removes all rules!
```

### Safe Production Debugging

**Never:**
- Disable UFW without understanding consequences
- Reset fail2ban without checking why it was blocking
- Modify SSH config without testing first
- Change VPN ports without checking firewall

**Always:**
- Make changes in dry-run mode first
- Commit config changes with clear rationale
- Test on non-production system first
- Keep backups of working configs
- Document what you changed and why

---

## 9. Deployment & Operations

### Deployment Steps

#### Initial Deployment (Greenfield)

```bash
# 1. Flash fresh Raspberry Pi OS to SD card
# 2. Insert SD card, power on Pi
# 3. SSH to Pi (or use HDMI/keyboard)

ssh pi@raspberrypi.local

# 4. Clone Pi Gateway repository
git clone https://github.com/1mb-dev/pi-gateway.git
cd pi-gateway

# 5. Run setup (interactive)
sudo make setup

# 6. Follow prompts:
#   - Confirm hardware type
#   - Set SSH key (generate or import)
#   - Configure VPN (set network range)
#   - Set domain name (DuckDNS)

# 7. Setup completes, prints summary
#   - SSH key location
#   - VPN config for clients
#   - Next steps
```

#### Updates (Existing Installation)

```bash
# 1. SSH to Pi
ssh pi@gateway.example.duckdns.org -i ~/.ssh/pi-gateway-key

# 2. Pull latest Pi Gateway
cd ~/pi-gateway
git pull origin main

# 3. Dry-run the setup to check for changes
sudo make setup --dry-run

# 4. If output shows changes you want, apply them
sudo make setup

# 5. Verify services still running
sudo systemctl status ssh
sudo systemctl status wg-quick@wg0
sudo ufw status
```

#### Rollback Procedure

If something breaks after updating:

```bash
# 1. Revert to last known-good commit
git revert <bad-commit>

# 2. Or restore from backup (if you made one)
sudo cp ~/.pi-gateway-backup/sshd_config /etc/ssh/sshd_config

# 3. Re-run setup to apply old configuration
sudo make setup

# 4. Verify services restored
sudo systemctl restart ssh
sudo systemctl restart wg-quick@wg0
```

### Operations: Day-2 Tasks

#### Managing SSH Access

**Add a new SSH key for another user:**
```bash
# 1. Get their public key (they run: ssh-keygen)
# 2. Add to ~/.ssh/authorized_keys
echo "ssh-rsa AAAA..." >> ~/.ssh/authorized_keys

# 3. They can now SSH in
ssh -i their-private-key pi@gateway.example.duckdns.org
```

**Remove SSH access for a user:**
```bash
# Edit authorized_keys and remove their key
nano ~/.ssh/authorized_keys
# Delete their line, save and exit

# They can no longer SSH in
```

#### Managing VPN Clients

```bash
# Add a new VPN client (e.g., laptop)
sudo ./scripts/vpn-client-manager.sh

# Follow prompts:
#   Name: "laptop"
#   Generate keys: yes
#   Create client config: yes

# Export config for user
sudo cat ~/.wireguard/clients/laptop.conf

# User imports into WireGuard app
# Connects to gateway on port 51820
```

**Remove VPN client:**
```bash
# Edit WireGuard config
sudo nano /etc/wireguard/wg0.conf

# Remove the [Peer] section for that client
# Save and restart

sudo systemctl restart wg-quick@wg0

# Client can no longer connect
```

#### Checking System Health

```bash
# Overall status
sudo systemctl status

# Key services
systemctl status ssh
systemctl status wg-quick@wg0
sudo ufw status

# Disk space (important on Pi)
df -h

# Memory usage
free -h

# Temperature (Pi-specific)
vcgencmd measure_temp
```

#### Applying Security Updates

```bash
# Check for updates
sudo apt-get update

# List updates
sudo apt-get upgrade --dry-run

# Apply updates
sudo apt-get upgrade -y

# Some updates need reboot
sudo reboot

# After reboot, verify services
systemctl status ssh
systemctl status wg-quick@wg0
```

### Handling Common Operational Issues

**Issue 1: SSH Keys Expire or Lost**

Recovery:
```bash
# If you have the server key backup
sudo scp root@pi:~/.ssh/id_rsa ~/backup/

# If you lost the key, use physical access
# 1. Connect keyboard + monitor to Pi
# 2. Generate new key: ssh-keygen
# 3. Add to authorized_keys
# 4. Or reset SSH: sudo apt-get install --reinstall openssh-server
```

**Issue 2: Firewall Locks You Out**

Recovery:
```bash
# Physical access required
# 1. Connect keyboard + monitor to Pi
# 2. Become root: sudo su
# 3. Check UFW: ufw status
# 4. Allow SSH: ufw allow 22
# 5. Or reset: ufw reset
```

**Issue 3: VPN Not Working**

Debugging:
```bash
# 1. Check WireGuard interface
ip link show wg0

# 2. Check it's listening
sudo ss -tlnp | grep 51820

# 3. Check firewall isn't blocking
sudo ufw status | grep 51820

# 4. Restart WireGuard
sudo systemctl restart wg-quick@wg0

# 5. Check logs
journalctl -u wg-quick@wg0 -n 20
```

---

## 10. Product & Feature Context

### What Pi Gateway Enables

Pi Gateway is the security foundation for a home infrastructure setup:

```
User Goals:
  ├─ Remote access to home network (anywhere)
  ├─ Do it securely (encrypted, authenticated)
  ├─ Set it up quickly (under 10 minutes)
  └─ Maintain it easily (automated)

Pi Gateway solves:
  ├─ SSH: Remote terminal access
  ├─ VPN: Encrypted tunnel to home network
  ├─ Firewall: Security boundary
  └─ Hardening: Defense against common attacks
```

### Feature Priorities

**Tier 1 (Core, Never Remove):**
- SSH with key-based auth
- WireGuard VPN
- UFW firewall
- System hardening

**Tier 2 (Common, Keep Updated):**
- fail2ban (brute-force protection)
- Dynamic DNS integration
- CLI management tool
- Documentation

**Tier 3 (Optional, Via Extensions):**
- Containers (Docker/Podman)
- Monitoring (Prometheus, Grafana)
- Backup (cloud integration)
- Dashboard (web UI)

### Roadmap & Open Questions

**Planned for Next Release:**
- Fix SC2116 linting warnings
- Consolidate hardening scripts
- Improve error messages
- Add dry-run to all scripts

**Under Consideration:**
- Web UI for client management (vs CLI tool)
- Mobile app for VPN management
- Automated backups to cloud
- Hardware acceleration for VPN

**Not Planned (Out of Scope):**
- Email server (complexity, use third-party)
- Web server (not remote access, use separate Pi)
- Kubernetes (overkill for homelab)
- IPv6 (not priority for v1.x)

### Success Metrics

What the business cares about:
- **Adoption:** Number of stars, forks, downloads
- **User Satisfaction:** GitHub issues (positive), discussions
- **Quality:** Test pass rate, security audits
- **Community:** Contributions, extensions built by others

---

## 11. Demo & Hands-On Walkthrough

### Quick Demo (10 minutes)

**Goal:** Show someone how Pi Gateway works

```bash
# 1. Show the repository structure
ls -la pi-gateway/

# 2. Show test results (prove it works)
make test  # All 40 tests pass

# 3. Show the main setup script
head -30 setup.sh

# 4. Show SSH hardening
grep "PasswordAuthentication" config/ssh_config

# 5. Show VPN configuration
cat config/wireguard.conf

# 6. Show documentation
ls docs/
```

### Hands-On: Setup Simulation (30 minutes)

**Goal:** Experience the setup flow (without a real Pi)

```bash
# 1. Clone the repository
git clone https://github.com/1mb-dev/pi-gateway.git
cd pi-gateway

# 2. Run validation (safe, read-only)
./scripts/check-requirements.sh

# 3. Run tests to verify everything works
make test

# 4. Inspect what would be installed
grep "apt-get install" scripts/install-dependencies.sh

# 5. Dry-run the SSH setup
./scripts/ssh-setup.sh --dry-run

# 6. Review the configurations that would be applied
cat config/ssh_config
cat config/wireguard.conf
```

### Hands-On Exercise: Deploy to Docker (45 minutes)

**Goal:** Actually deploy Pi Gateway in a container

```bash
# 1. Start Docker-based Pi simulation
./tests/docker/quick-e2e-test.sh

# 2. Watch the setup happen in real-time
#    (scripts installing, services starting)

# 3. Once done, access the container
docker exec -it pi-gateway bash

# 4. Verify services are running
systemctl status ssh
systemctl status wg-quick@wg0

# 5. Test SSH connection
ssh -i tests/docker/id_rsa pi@localhost -p 2222

# 6. Inspect configurations
cat /etc/ssh/sshd_config
wg show wg0

# 7. Clean up
docker stop pi-gateway
```

### Key API/Commands to Try

**SSH Operations:**
```bash
# Generate SSH key
ssh-keygen -t ed25519 -f ~/.ssh/pi-gateway-key -N ""

# SSH to gateway
ssh -i ~/.ssh/pi-gateway-key pi@gateway.example.duckdns.org

# Copy a file via SSH
scp -i ~/.ssh/pi-gateway-key ~/myfile.txt pi@gateway.example.duckdns.org:/home/pi/
```

**VPN Operations:**
```bash
# View active clients
sudo wg show wg0

# Add new client
sudo ./scripts/vpn-client-manager.sh

# Generate QR code for mobile
sudo wg show wg0 peers | qrencode -t ANSI256
```

**Management Commands:**
```bash
# Check system health
./scripts/service-status.sh

# View logs
journalctl -u ssh
journalctl -u wg-quick@wg0

# Reload configurations
sudo systemctl restart ssh
sudo systemctl restart wg-quick@wg0
```

---

## 12. FAQs for New Developers

**Q: How do I test my changes before deploying?**
A: Use `make test` for local validation, then `./tests/docker/quick-e2e-test.sh` for Docker-based deployment simulation.

**Q: What if my changes break SSH and I can't access the Pi?**
A: You'll need physical access. Connect keyboard + monitor, log in locally, and manually fix the config. Use `sshd -t` to test syntax.

**Q: Should I hardcode passwords or secrets?**
A: Never. Secrets should be injected at runtime or managed externally (e.g., environment variables). Check `scripts/common.sh` for pattern.

**Q: How do I debug a failing test?**
A: Run with `bash -x script.sh` to trace execution, or add `set -v` to see each line as it runs.

**Q: Who approves security-related changes?**
A: Maintainers review all changes. Security changes require additional scrutiny and may need external audit.

**Q: Can I add a new optional feature?**
A: Yes, as an extension in `extensions/`. Keep core focused on SSH + VPN + Firewall.

**Q: How is versioning handled?**
A: Semantic versioning (v1.2.0 = major.minor.patch). Maintainers decide when to release.

**Q: What if I find a security vulnerability?**
A: Report privately to maintainers (don't open public issue). They'll assess and coordinate a fix.

**Q: How long do I have to test before merging?**
A: At minimum: all tests pass, code review done. Security changes may need 1-2 week community testing period.

**Q: Can I remove old documentation?**
A: Only if updating to newer docs. Never delete docs without replacement - someone is using them.

**Q: Who maintains the Docker test images?**
A: Maintainers update periodically. File issue if tests are failing due to stale base image.

---

## Onboarding Checklist

Before your first contribution:

- [ ] Read this document (you're doing it!)
- [ ] Clone the repository locally
- [ ] Run `make test` to verify baseline (should be 40/40 passing)
- [ ] Read one guide from `docs/` (pick interesting one)
- [ ] Try the hands-on demo exercises above
- [ ] Find a "good-first-issue" on GitHub
- [ ] Make your first contribution (small fix or doc improvement)
- [ ] Run tests and get code review
- [ ] Deploy to production on your own Pi (optional, after 3-5 contributions)

---

## Key Resources

**In This Repository:**
- `README.md` — Quick overview
- `docs/quick-start.md` — 15-minute setup guide
- `docs/setup-guide.md` — Detailed installation
- `docs/usage.md` — Day-to-day operations
- `Makefile` — Available commands

**External Resources:**
- [SSH Best Practices](https://man.openbsd.org/sshd_config)
- [WireGuard Documentation](https://www.wireguard.com/install/)
- [UFW (Uncomplicated Firewall)](https://wiki.ubuntu.com/UncomplicatedFirewall)
- [BATS Testing Framework](https://bats-core.readthedocs.io/)

**Getting Help:**
- GitHub Issues: Report bugs or ask questions
- Discussions: Longer-form conversations
- PR comments: Direct technical feedback
- Email: (Maintainer contact, if provided)

---

## Next Steps

1. **Review** this document (highlight sections you need)
2. **Explore** the codebase (`scripts/`, `tests/`, `docs/`)
3. **Try** the hands-on exercises
4. **Practice** with your own contributions
5. **Contribute** your first improvement
6. **Review** others' PRs to learn even more

---

*Knowledge Transfer Guide for Pi Gateway | v1.2.0 | 2026-03-01*
*For questions or updates, open an issue on GitHub*
