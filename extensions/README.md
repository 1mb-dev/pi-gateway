# Pi Gateway Extensions

Optional features for advanced users. Core Pi Gateway provides secure remote access (SSH + VPN + Firewall). Extensions add additional functionality.

## Available Extensions

### Container Support
**Location:** `extensions/containers/`
**Features:** Docker/Podman setup, container orchestration, Portainer management
**Use case:** Run containerized services on your Pi

### Status Dashboard
**Location:** `extensions/dashboard/`
**Features:** Web-based status monitoring, service health checks
**Use case:** Visual monitoring of Pi Gateway services

### Cloud Backup
**Location:** `extensions/backup/`
**Features:** Automated backups to cloud storage (rclone-based)
**Use case:** Backup configurations to cloud providers

### Network Optimization
**Location:** `extensions/network/`
**Features:** TCP tuning, bandwidth management, QoS
**Use case:** Performance optimization for specific workloads

### Auto Maintenance
**Location:** `extensions/maintenance/`
**Features:** Automated updates, system cleanup, health checks
**Use case:** Hands-off system maintenance

### Monitoring
**Location:** `extensions/monitoring/`
**Features:** Metrics collection, alerting, log aggregation
**Use case:** Production-grade monitoring setup

## Installation

Extensions are standalone and optional. Each extension directory contains:
- Installation script
- Configuration files
- Documentation

**Example:**
```bash
cd extensions/containers
sudo ./container-support.sh
```

## Compatibility

Extensions require Pi Gateway core to be installed first. Some extensions may have additional dependencies or resource requirements.

## Support

Extensions are community-supported and may have different maintenance schedules than core Pi Gateway.
