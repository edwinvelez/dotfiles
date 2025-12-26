#!/usr/bin/env bash

# Colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' 

echo -e "${BLUE}>>> Starting Edwin Velez's Dotfile Deployment <<<${NC}"

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo -e "${RED}Error: GNU Stow is not installed. Please install it first.${NC}"
    exit 1
fi

# Ensure we are in the dotfiles directory
cd "$(dirname "$0")"

# 1. Deploy Common and Binaries
echo -e "${GREEN}Deploying: common, bin...${NC}"
stow -vt ~ common bin

# 2. Hostname-based Deployment
HOSTNAME=$(hostname)

if [[ "$HOSTNAME" == "my-desktop" ]]; then
    echo -e "${GREEN}Detected: Desktop. Deploying: desktop...${NC}"
    stow -vt ~ desktop
elif [[ "$HOSTNAME" == "my-laptop" ]]; then
    echo -e "${GREEN}Detected: Laptop. Deploying: laptop...${NC}"
    stow -vt ~ laptop
else
    echo -e "${BLUE}Detected: VM/Other ($HOSTNAME). Defaulting to Laptop profile...${NC}"
    stow -vt ~ laptop
fi

echo -e "${GREEN}Done! Everything is stowed.${NC}"
