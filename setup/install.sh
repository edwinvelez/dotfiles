#!/usr/bin/env bash
# ==============================================================================
# Unified Host Provisioning & Service Orchestration Script
# Target: Arch Linux (Desktop & Laptop Profiles)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

DRY_RUN=0
PROFILE=""

# ------------------------------------------------------------------------------
# Logging Utilities
# ------------------------------------------------------------------------------
log_info() {
    printf "[INFO] %s\n" "$*"
}

log_success() {
    printf "[SUCCESS] %s\n" "$*"
}

log_warn() {
    printf "[WARN] %s\n" "$*"
}

log_error() {
    printf "[ERROR] %s\n" "$*" >&2
}

# ------------------------------------------------------------------------------
# Argument Parsing & Profile Detection
# ------------------------------------------------------------------------------
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Automated provisioning script for Arch Linux systems managed via chezmoi.

Options:
    -d, --desktop     Force Desktop profile (my-desktop)
    -l, --laptop      Force Laptop profile (my-laptop / Dell XPS 15)
    -a, --auto        Auto-detect profile via hardware chassis/hostname (default)
    -n, --dry-run     Print actions without executing package installation or service changes
    -h, --help        Show this help message

EOF
    exit 0
}

detect_profile() {
    local chassis
    chassis="$(hostnamectl chassis 2>/dev/null || echo "unknown")"
    local hostname
    hostname="$(uname -n 2>/dev/null || echo "unknown")"

    if [[ "${chassis}" == "laptop" ]] || [[ "${chassis}" == "convertible" ]] || [[ "${hostname}" =~ laptop ]]; then
        echo "laptop"
    elif [[ "${chassis}" == "desktop" ]] || [[ "${hostname}" =~ desktop ]]; then
        echo "desktop"
    else
        echo "unknown"
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--desktop)
            PROFILE="desktop"
            shift
            ;;
        -l|--laptop)
            PROFILE="laptop"
            shift
            ;;
        -a|--auto)
            PROFILE="auto"
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=1
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Unknown argument: $1"
            usage
            ;;
    esac
done

if [[ -z "${PROFILE}" ]] || [[ "${PROFILE}" == "auto" ]]; then
    PROFILE="$(detect_profile)"
    if [[ "${PROFILE}" == "unknown" ]]; then
        log_error "Failed to auto-detect system chassis. Specify --desktop or --laptop explicitly."
        exit 1
    fi
fi

log_info "Target machine profile: ${PROFILE}"
if [[ ${DRY_RUN} -eq 1 ]]; then
    log_warn "Running in DRY-RUN mode. No system changes will be applied."
fi

# ------------------------------------------------------------------------------
# Dependency Verification
# ------------------------------------------------------------------------------
if ! command -v paru >/dev/null 2>&1; then
    log_error "AUR helper 'paru' is not installed. Please install paru before running this script."
    exit 1
fi

# ------------------------------------------------------------------------------
# Package Manifest Collection
# ------------------------------------------------------------------------------
read_manifest() {
    local file="$1"
    if [[ -f "${file}" ]]; then
        grep -vE '^\s*#|^\s*$' "${file}" | tr -d '\r' || true
    fi
}

COMMON_PKGS_FILE="${SCRIPT_DIR}/packages-common.txt"
PROFILE_PKGS_FILE="${SCRIPT_DIR}/packages-${PROFILE}.txt"

mapfile -t COMMON_PACKAGES < <(read_manifest "${COMMON_PKGS_FILE}")
mapfile -t PROFILE_PACKAGES < <(read_manifest "${PROFILE_PKGS_FILE}")

ALL_PACKAGES=("${COMMON_PACKAGES[@]}" "${PROFILE_PACKAGES[@]}")

log_info "Discovered ${#COMMON_PACKAGES[@]} common packages and ${#PROFILE_PACKAGES[@]} ${PROFILE}-specific packages."

# ------------------------------------------------------------------------------
# Package Installation
# ------------------------------------------------------------------------------
if [[ ${DRY_RUN} -eq 1 ]]; then
    log_info "[Dry-Run] Would install ${#ALL_PACKAGES[@]} packages via paru:"
    printf "  - %s\n" "${ALL_PACKAGES[@]}"
else
    log_info "Invoking paru to install missing packages..."
    paru -S --needed --noconfirm "${ALL_PACKAGES[@]}"
    log_success "Package installation completed."
fi

# ------------------------------------------------------------------------------
# Service Manifest Collection & Activation
# ------------------------------------------------------------------------------
COMMON_SVCS_FILE="${SCRIPT_DIR}/services-common.txt"
PROFILE_SVCS_FILE="${SCRIPT_DIR}/services-${PROFILE}.txt"

mapfile -t COMMON_SERVICES < <(read_manifest "${COMMON_SVCS_FILE}")
mapfile -t PROFILE_SERVICES < <(read_manifest "${PROFILE_SVCS_FILE}")

ALL_SERVICES=("${COMMON_SERVICES[@]}" "${PROFILE_SERVICES[@]}")

log_info "Discovered ${#COMMON_SERVICES[@]} common services and ${#PROFILE_SERVICES[@]} ${PROFILE}-specific services."

if [[ ${DRY_RUN} -eq 1 ]]; then
    log_info "[Dry-Run] Would configure ${#ALL_SERVICES[@]} systemd units:"
    for service in "${ALL_SERVICES[@]}"; do
        if [[ "${service}" =~ nvidia-(suspend|hibernate|resume) ]]; then
            printf "  - %s (enable hook only, without --now)\n" "${service}"
        else
            printf "  - %s (enable --now)\n" "${service}"
        fi
    done
else
    log_info "Enabling and starting systemd units..."
    for service in "${ALL_SERVICES[@]}"; do
        # Sleep and resume hooks must ONLY be enabled, NEVER started in an active session
        if [[ "${service}" =~ nvidia-(suspend|hibernate|resume) ]]; then
            if sudo systemctl enable "${service}" 2>/dev/null; then
                log_success "Enabled (hook): ${service}"
            else
                log_warn "Failed to enable hook: ${service} (verify unit availability)"
            fi
        else
            if sudo systemctl enable --now "${service}" 2>/dev/null; then
                log_success "Enabled & started: ${service}"
            else
                log_warn "Failed to enable or start: ${service} (verify unit availability)"
            fi
        fi
    done
fi

# ------------------------------------------------------------------------------
# Storage Optimization (Btrfs NOCOW Attributes)
# ------------------------------------------------------------------------------
NOCOW_DIRS=(
    "${HOME}/Dropbox"
    "${HOME}/VirtualBox VMs"
)

if [[ ${DRY_RUN} -eq 1 ]]; then
    log_info "[Dry-Run] Would enforce Btrfs NOCOW (+C) on:"
    printf "  - %s\n" "${NOCOW_DIRS[@]}"
else
    log_info "Enforcing Btrfs NOCOW (+C) attributes on high-write directories..."
    for dir in "${NOCOW_DIRS[@]}"; do
        mkdir -p "${dir}"
        if chattr +C "${dir}" 2>/dev/null; then
            log_success "Applied NOCOW (+C): ${dir}"
        else
            log_warn "Failed to apply NOCOW (+C) on ${dir} (non-Btrfs or non-empty)"
        fi
    done
fi

# ------------------------------------------------------------------------------
# Configuration Synchronization via chezmoi
# ------------------------------------------------------------------------------
if command -v chezmoi >/dev/null 2>&1; then
    if [[ ${DRY_RUN} -eq 1 ]]; then
        log_info "[Dry-Run] Would execute: chezmoi apply --source ${DOTFILES_DIR}"
    else
        log_info "Applying chezmoi dotfiles configurations..."
        chezmoi apply --source "${DOTFILES_DIR}"
        log_success "Chezmoi configuration synchronization completed."
    fi
else
    log_warn "chezmoi binary not found in PATH; skipping configuration application."
fi

log_success "System provisioning for [${PROFILE}] completed successfully."
