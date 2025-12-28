#!/usr/bin/env bash

# Set strict error handling
set -e

# Define Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default variables
ACTION="-S"       # Default to Stow (Install)
MODE_VERB="Stowing"
SIMULATE=""       # Default to real execution
TARGET_HOME="$HOME"
DOTFILES_DIR="$(dirname "$(realpath "$0")")"

# --- Helper Functions ---

usage() {
    echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
    echo "Options:"
    echo "  -n, --dry-run   Simulate the operation (don't make changes)"
    echo "  -d, --delete    Unstow (remove symlinks) for ALL packages"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Example: $0 --dry-run (Preview changes)"
    echo "Example: $0 --delete  (Factory Reset - removes all links)"
}

check_stow() {
    if ! command -v stow &> /dev/null; then
        echo -e "${RED}Error: GNU Stow is not installed. Please install it first.${NC}"
        exit 1
    fi
}

run_stow() {
    local package=$1
    if [[ -d "$DOTFILES_DIR/$package" ]]; then
        echo -e "${BLUE}:: $MODE_VERB package: ${YELLOW}$package${NC}"
        # We allow stow to fail (e.g. if unstowing a package that isn't there)
        # 2>/dev/null suppresses "not stowed" errors during cleanup for a cleaner log
        stow $SIMULATE -v $ACTION -t "$TARGET_HOME" "$package" 2>/dev/null || true
    else
        echo -e "${RED}!! Package '$package' not found in $DOTFILES_DIR. Skipping.${NC}"
    fi
}

# --- Argument Parsing ---

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--dry-run) SIMULATE="-n"; shift ;;
        -d|--delete)  ACTION="-D"; MODE_VERB="Unstowing"; shift ;;
        -h|--help)    usage; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; usage; exit 1 ;;
    esac
done

# --- Main Execution ---

echo -e "${BLUE}>>> Edwin Velez Dotfiles Manager <<<${NC}"
check_stow

# Ensure we are in the dotfiles root
cd "$DOTFILES_DIR"

if [[ -n "$SIMULATE" ]]; then
    echo -e "${YELLOW}[DRY-RUN MODE ENABLED] No changes will be made.${NC}"
fi

# 1. Base Layers (Always processed)
echo -e "${GREEN}==> Processing Base Layers${NC}"
run_stow "common"
run_stow "bin"

# 2. Hardware Layers
if [[ "$ACTION" == "-D" ]]; then
    # DELETE MODE: Nukes everything (Desktop AND Laptop) to ensure clean slate
    echo -e "${GREEN}==> Unstowing ALL Hardware Profiles (Factory Reset)${NC}"
    run_stow "desktop"
    run_stow "laptop"
else
    # INSTALL MODE: Ask the user which one to apply
    echo -e "\n${GREEN}==> Select Hardware Profile${NC}"
    PS3="Select profile (Enter number): "
    options=("Desktop (Nvidia/High-Perf)" "Laptop (Intel/Battery/Scaling)" "Skip Hardware Layer")

    select opt in "${options[@]}"
    do
        case $opt in
            "Desktop (Nvidia/High-Perf)")
                run_stow "desktop"
                break
                ;;
            "Laptop (Intel/Battery/Scaling)")
                run_stow "laptop"
                break
                ;;
            "Skip Hardware Layer")
                echo "Skipping hardware specific config..."
                break
                ;;
            *) echo "Invalid option $REPLY";;
        esac
    done
fi

echo -e "\n${GREEN}Success! Operation complete.${NC}"
