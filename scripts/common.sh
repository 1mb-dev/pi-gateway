#!/bin/bash
#
# Pi Gateway - Common Utilities
# Shared functions and constants
#

# Ensure this file is sourced only once
if [[ -n "${PI_GATEWAY_COMMON_LOADED:-}" ]]; then
    return 0
fi
readonly PI_GATEWAY_COMMON_LOADED=1

# Script information
readonly PI_GATEWAY_VERSION="1.2.0"
readonly PI_GATEWAY_ROOT="${PI_GATEWAY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Common paths
readonly PI_GATEWAY_LOG_DIR="/var/log/pi-gateway"
readonly PI_GATEWAY_CONFIG_DIR="/etc/pi-gateway"
readonly PI_GATEWAY_BACKUP_DIR="/var/backups/pi-gateway"
readonly PI_GATEWAY_RUN_DIR="/var/run/pi-gateway"

# System constants
readonly MIN_RAM_MB=1024
readonly MIN_STORAGE_GB=8
readonly DEFAULT_SSH_PORT=2222
readonly DEFAULT_VPN_PORT=51820
readonly DEFAULT_VNC_PORT=5901

# Dry-run support
DRY_RUN="${DRY_RUN:-false}"
VERBOSE_DRY_RUN="${VERBOSE_DRY_RUN:-false}"

# Initialize logging
init_logging() {
    local script_name="${1:-$(basename "$0")}"
    local log_file="${2:-/tmp/pi-gateway-${script_name%%.sh}.log}"

    export PI_GATEWAY_LOG_FILE="$log_file"

    local log_dir
    log_dir="$(dirname "$log_file")"
    [[ -d "$log_dir" ]] || mkdir -p "$log_dir"

    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting $script_name" > "$log_file"
}

# Logging functions - plain text only
log() {
    local level="${1:-INFO}"
    shift
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $level: $*" | tee -a "${PI_GATEWAY_LOG_FILE:-/tmp/pi-gateway.log}"
}

success() {
    echo "[OK] $1"
    log "SUCCESS" "$1"
}

error() {
    echo "[ERROR] $1" >&2
    log "ERROR" "$1"
}

warning() {
    echo "[WARNING] $1"
    log "WARN" "$1"
}

info() {
    echo "[INFO] $1"
    log "INFO" "$1"
}

debug() {
    if [[ "${VERBOSE_DRY_RUN:-false}" == "true" ]]; then
        echo "[DEBUG] $1"
        log "DEBUG" "$1"
    fi
}

progress() {
    echo "[PROGRESS] $1"
    log "PROGRESS" "$1"
}

# Testing and mocking utilities
is_dry_run() {
    [[ "${DRY_RUN:-false}" == "true" ]]
}

is_mocked() {
    local component="${1:-}"
    [[ "${MOCK_MODE:-false}" == "true" ]] || [[ "${PI_GATEWAY_TESTING:-false}" == "true" ]]
}

# Dry-run execution wrapper
execute_command() {
    local cmd="$*"

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY-RUN] $cmd"
        log "DRY-RUN" "$cmd"
        return 0
    else
        debug "Executing: $cmd"
        eval "$cmd"
    fi
}

# System check functions
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (use sudo)"
        return 1
    fi
}

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        error "Cannot determine operating system"
        return 1
    fi

    # shellcheck source=/dev/null
    source /etc/os-release

    if [[ "$ID" != "raspbian" ]] && [[ "$ID_LIKE" != *"debian"* ]]; then
        warning "Untested OS: $PRETTY_NAME"
    fi
}

# Network utilities
get_primary_ip() {
    hostname -I | awk '{print $1}'
}

check_internet() {
    local test_hosts=("8.8.8.8" "1.1.1.1")
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W 3 "$host" >/dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}

# Service management
ensure_service() {
    local service="$1"
    local action="${2:-enable}"

    case "$action" in
        enable|start|restart|stop)
            execute_command "systemctl $action $service"
            ;;
        *)
            error "Invalid service action: $action"
            return 1
            ;;
    esac
}

# File operations
backup_file() {
    local file="$1"
    local backup_dir="${2:-$PI_GATEWAY_BACKUP_DIR}"
    local timestamp
    timestamp="$(date +%Y%m%d_%H%M%S)"

    if [[ -f "$file" ]]; then
        execute_command "mkdir -p '$backup_dir'"
        execute_command "cp '$file' '$backup_dir/$(basename "$file").$timestamp'"
        success "Backed up $file"
    fi
}

# Error handling
cleanup_on_exit() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        error "Script failed with exit code $exit_code"
        if [[ -n "${PI_GATEWAY_LOG_FILE:-}" ]]; then
            echo "Check log file: ${PI_GATEWAY_LOG_FILE}"
        fi
    fi
}

# Set up common error handling
trap cleanup_on_exit EXIT

# Load test mocks if in test environment
load_test_mocks() {
    local script_dir
    script_dir="$(dirname "${BASH_SOURCE[0]}")"

    for mock_file in common system hardware network; do
        local mock_path="$script_dir/../tests/mocks/$mock_file.sh"
        if [[ -f "$mock_path" ]]; then
            # shellcheck source=/dev/null
            source "$mock_path"
        fi
    done
}

# Auto-load test mocks if available
if [[ "${DRY_RUN:-false}" == "true" ]] || [[ -n "${MOCK_HARDWARE:-}" ]]; then
    load_test_mocks
fi
