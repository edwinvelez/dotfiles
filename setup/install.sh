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

# ------------------------------------------------------------------------------
# Package Installation (Two-Phase Resolution)
# ------------------------------------------------------------------------------
# Phase 1: Install hardware-specific profile packages first (drivers/kernel/AUR)
# to satisfy virtual dependencies (e.g., lib32-vulkan-driver via lib32-nvidia-580xx-utils)
# before general application dependency trees are resolved.
# Phase 2: Install common packages.
if [[ ${DRY_RUN} -eq 1 ]]; then
    log_info "[Dry-Run] Would install ${#PROFILE_PACKAGES[@]} ${PROFILE} packages:"
    printf "  - %s\n" "${PROFILE_PACKAGES[@]}"
    log_info "[Dry-Run] Would install ${#COMMON_PACKAGES[@]} common packages:"
    printf "  - %s\n" "${COMMON_PACKAGES[@]}"
else
    if [[ ${#PROFILE_PACKAGES[@]} -gt 0 ]]; then
        log_info "Phase 1: Installing ${#PROFILE_PACKAGES[@]} ${PROFILE}-specific packages..."
        paru -S --needed --noconfirm "${PROFILE_PACKAGES[@]}"
    fi

    if [[ ${#COMMON_PACKAGES[@]} -gt 0 ]]; then
        log_info "Phase 2: Installing ${#COMMON_PACKAGES[@]} common packages..."
        paru -S --needed --noconfirm "${COMMON_PACKAGES[@]}"
    fi
    log_success "Package installation completed."
fi

# ------------------------------------------------------------------------------
# Docker Engine Configuration
# ------------------------------------------------------------------------------
# The root partition is too small for images and VM disks. Docker's data-root lives
# on /home in a dedicated subvolume so snapper's /home snapshots exclude it.
DOCKER_DATA_ROOT="/home/docker"
DOCKER_DAEMON_JSON="${SCRIPT_DIR}/docker-daemon.json"

if [[ ${DRY_RUN} -eq 1 ]]; then
    log_info "[Dry-Run] Would create subvolume ${DOCKER_DATA_ROOT}, install /etc/docker/daemon.json, and add ${USER} to the docker group"
else
    log_info "Configuring Docker engine..."
    if [[ ! -d "${DOCKER_DATA_ROOT}" ]]; then
        sudo btrfs subvolume create "${DOCKER_DATA_ROOT}" >/dev/null
        sudo chmod 710 "${DOCKER_DATA_ROOT}"
    fi
    sudo install -Dm644 "${DOCKER_DAEMON_JSON}" /etc/docker/daemon.json
    sudo usermod -aG docker "${USER}"
    log_success "Docker data-root set to ${DOCKER_DATA_ROOT}; ${USER} added to docker group"
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
# Storage Optimization (Btrfs NOCOW Subvolumes)
# ------------------------------------------------------------------------------
# Each directory is created as its own subvolume so snapper's /home snapshots
# skip it; a snapshot forces a one-time CoW on every later write to NOCOW files.
NOCOW_DIRS=(
    "${HOME}/.local/share/Steam"
    "${HOME}/.local/share/docker-volumes"
)

if [[ ${DRY_RUN} -eq 1 ]]; then
    log_info "[Dry-Run] Would create Btrfs subvolumes and enforce NOCOW (+C) on:"
    printf "  - %s\n" "${NOCOW_DIRS[@]}"
else
    log_info "Enforcing Btrfs NOCOW (+C) subvolumes on high-write directories..."
    for dir in "${NOCOW_DIRS[@]}"; do
        if [[ ! -d "${dir}" ]]; then
            mkdir -p "$(dirname "${dir}")"
            btrfs subvolume create "${dir}" >/dev/null
        fi
        if chattr +C "${dir}" 2>/dev/null; then
            log_success "Applied NOCOW (+C) subvolume: ${dir}"
        else
            log_warn "Failed to apply NOCOW (+C) on ${dir} (non-Btrfs)"
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
