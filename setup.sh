#!/bin/bash
#
# Pi Gateway - Setup Script
# Secure remote access gateway for Raspberry Pi
#

# Check Bash version (need 4.0+)
if [[ ${BASH_VERSION%%.*} -lt 4 ]]; then
    echo "[ERROR] This script requires Bash 4.0 or later"
    echo "Current version: $BASH_VERSION"
    exit 1
fi

# Set strict error handling
set -eo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/common.sh"

# Configuration
readonly CONFIG_FILE="$SCRIPT_DIR/config/setup.conf"

# Setup phases
readonly PHASES=(
    "requirements"
    "dependencies"
    "hardening"
    "ssh"
    "vpn"
    "firewall"
    "remote-desktop"
    "ddns"
)

declare -A PHASE_SCRIPTS=(
    ["requirements"]="scripts/check-requirements.sh"
    ["dependencies"]="scripts/install-dependencies.sh"
    ["hardening"]="scripts/system-hardening.sh"
    ["ssh"]="scripts/ssh-setup.sh"
    ["vpn"]="scripts/vpn-setup.sh"
    ["firewall"]="scripts/firewall-setup.sh"
    ["remote-desktop"]="scripts/remote-desktop.sh"
    ["ddns"]="scripts/ddns-setup.sh"
)

declare -A PHASE_NAMES=(
    ["requirements"]="System Requirements"
    ["dependencies"]="Dependencies"
    ["hardening"]="System Hardening"
    ["ssh"]="SSH Setup"
    ["vpn"]="VPN Setup"
    ["firewall"]="Firewall"
    ["remote-desktop"]="Remote Desktop"
    ["ddns"]="Dynamic DNS"
)

# Setup options
INTERACTIVE_MODE=true
DRY_RUN="${DRY_RUN:-false}"
SELECTED_PHASES=()
SETUP_ERROR_COUNT=0

# Show help
show_help() {
    echo "Pi Gateway Setup - Secure Remote Access Gateway"
    echo ""
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -d, --dry-run        Run without making system changes"
    echo "  -n, --non-interactive  Run without prompts (full install)"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")              # Interactive setup"
    echo "  $(basename "$0") --dry-run    # Test without changes"
    echo ""
}

# Parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -n|--non-interactive)
                INTERACTIVE_MODE=false
                shift
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Interactive component selection
select_components() {
    echo ""
    echo "Pi Gateway Setup"
    echo "================"
    echo ""
    echo "Select installation type:"
    echo "  1. Full Installation (All components)"
    echo "  2. Core Security (SSH + VPN + Firewall)"
    echo "  3. Custom Selection"
    echo ""

    while true; do
        read -r -p "Choice [1-3]: " choice
        case $choice in
            1)
                SELECTED_PHASES=("${PHASES[@]}")
                info "Selected: Full Installation"
                break
                ;;
            2)
                SELECTED_PHASES=("requirements" "dependencies" "hardening" "ssh" "vpn" "firewall")
                info "Selected: Core Security"
                break
                ;;
            3)
                select_custom_components
                break
                ;;
            *)
                warning "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

# Custom component selection
select_custom_components() {
    echo ""
    info "Core components (always included):"
    echo "  - System Requirements"
    echo "  - Dependencies"
    echo "  - System Hardening"
    echo "  - SSH Setup"
    echo ""

    SELECTED_PHASES=("requirements" "dependencies" "hardening" "ssh")

    # VPN
    read -r -p "Install VPN (WireGuard)? [Y/n]: " response
    if [[ ! "$response" =~ ^[Nn]$ ]]; then
        SELECTED_PHASES+=("vpn")
    fi

    # Firewall
    read -r -p "Install Firewall? [Y/n]: " response
    if [[ ! "$response" =~ ^[Nn]$ ]]; then
        SELECTED_PHASES+=("firewall")
    fi

    # Remote Desktop
    read -r -p "Install Remote Desktop (VNC)? [y/N]: " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        SELECTED_PHASES+=("remote-desktop")
    fi

    # DDNS
    read -r -p "Install Dynamic DNS? [y/N]: " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        SELECTED_PHASES+=("ddns")
    fi
}

# Execute a single phase
execute_phase() {
    local phase="$1"
    local script="${PHASE_SCRIPTS[$phase]}"
    local name="${PHASE_NAMES[$phase]}"

    info "Starting: $name"

    if [[ ! -f "$script" ]]; then
        error "Script not found: $script"
        return 1
    fi

    export DRY_RUN

    if "$script"; then
        success "Completed: $name"
        return 0
    else
        error "Failed: $name"
        ((SETUP_ERROR_COUNT++))
        return 1
    fi
}

# Run all selected phases
run_setup_phases() {
    local total_phases=${#SELECTED_PHASES[@]}
    local completed=0
    local failed=0

    info "Starting Pi Gateway setup ($total_phases phases)"
    echo ""

    for phase in "${SELECTED_PHASES[@]}"; do
        ((completed++))
        echo "[$completed/$total_phases] ${PHASE_NAMES[$phase]}"
        echo "----------------------------------------"

        if execute_phase "$phase"; then
            echo ""
        else
            ((failed++))

            if [[ "$INTERACTIVE_MODE" == "true" ]]; then
                read -r -p "Continue with remaining phases? [y/N]: " response
                if [[ ! "$response" =~ ^[Yy]$ ]]; then
                    error "Setup aborted by user"
                    return 1
                fi
            else
                error "Aborting non-interactive setup after failure"
                return 1
            fi
        fi
    done

    echo ""
    if [[ $failed -eq 0 ]]; then
        success "Setup completed successfully"
        return 0
    else
        warning "Setup completed with $failed failures"
        return 1
    fi
}

# Show connection information
show_connection_info() {
    echo ""
    echo "Connection Information"
    echo "======================"
    echo ""

    local local_ip
    local_ip=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "192.168.1.x")

    echo "SSH Access:"
    echo "  ssh -p 2222 pi@$local_ip"
    echo ""

    if [[ " ${SELECTED_PHASES[*]} " =~ " vpn " ]]; then
        echo "VPN Access:"
        echo "  Server: $local_ip:51820"
        echo "  Add clients: sudo ./scripts/vpn-client-manager.sh add <name>"
        echo ""
    fi

    if [[ " ${SELECTED_PHASES[*]} " =~ " remote-desktop " ]]; then
        echo "Remote Desktop:"
        echo "  VNC: $local_ip:5900"
        echo ""
    fi
}

# Show next steps
show_next_steps() {
    echo "Next Steps"
    echo "=========="
    echo ""
    echo "1. Configure router port forwarding:"
    echo "   - Port 2222 for SSH"
    if [[ " ${SELECTED_PHASES[*]} " =~ " vpn " ]]; then
        echo "   - Port 51820 for VPN"
    fi
    echo ""
    echo "2. Test connectivity from another device"
    echo ""
    echo "3. Check service status:"
    echo "   systemctl status ssh"
    if [[ " ${SELECTED_PHASES[*]} " =~ " vpn " ]]; then
        echo "   systemctl status wg-quick@wg0"
    fi
    echo ""
}

# Main execution
main() {
    # Parse arguments
    parse_arguments "$@"

    # Initialize
    info "Pi Gateway v${PI_GATEWAY_VERSION}"
    echo ""

    if [[ "$DRY_RUN" == "true" ]]; then
        warning "DRY RUN MODE - No system changes will be made"
        echo ""
    fi

    # Component selection
    if [[ "$INTERACTIVE_MODE" == "true" ]]; then
        select_components
        echo ""
        read -r -p "Proceed with installation? [Y/n]: " response
        if [[ "$response" =~ ^[Nn]$ ]]; then
            info "Installation cancelled"
            exit 0
        fi
        echo ""
    else
        SELECTED_PHASES=("${PHASES[@]}")
        info "Running non-interactive setup (all components)"
        echo ""
    fi

    # Run setup
    local start_time
    start_time=$(date +%s)

    if run_setup_phases; then
        local end_time
        end_time=$(date +%s)
        local duration=$((end_time - start_time))

        echo ""
        success "Pi Gateway setup completed in ${duration}s"
        echo ""

        show_connection_info
        show_next_steps

        return 0
    else
        error "Pi Gateway setup failed"
        return 1
    fi
}

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
