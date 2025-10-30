#!/bin/bash
#
# user_setup.sh - User-Specific Environment Setup Script
#
# This script should be run by a standard user (NOT as root) after the main
# 'sudo_setup.sh' script has completed. It installs an AUR helper, AUR
# packages, and configures user-specific applications and shells.
#

# --- Root User Check ---
# This script is designed to run as a standard user. It will exit if
# it is accidentally run with root privileges.
if [[ $EUID -eq 0 ]]; then
   echo "Error: This script must be run as a standard user, not as root." >&2
   exit 1
fi

# --- Script Safety ---
set -e
set -u
set -o pipefail

# --- User Configuration ---
# The USER and HOME variables are automatically set by the shell.
USERNAME="$USER"
USER_HOME="$HOME"

# --- Package Lists ---
# All packages to be installed by the user are consolidated here.
# 'paru' will handle packages from both the official repositories and the AUR.
PACKAGES_TO_INSTALL=(
    # --- Official Repository Dependencies ---
    "libappindicator-gtk3" # Required by Dropbox
    "python-gpgme"         # Required by Dropbox

    # --- Arch User Repository (AUR) Packages ---
    "dropbox"
    "thunar-dropbox"
    "google-chrome"
    "grimblast"
    "nwg-look"
    "virtualbox-ext-oracle"
    "visual-studio-code-bin"
    "zoom"
)

# --- Functions ---

#
# Installs 'paru', a popular AUR helper, if it's not already present.
# 'paru' is used to simplify the installation of packages from the AUR.
#
install_paru() {
    echo "--> Checking for and installing paru (AUR helper)..."
    if ! command -v paru &> /dev/null; then
        echo "paru not found. Installing now..."
        # makepkg requires dependencies from 'base-devel', which sudo_setup.sh installs.
        # It will prompt for a sudo password to install the final package.
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        (cd /tmp/paru && makepkg -si --noconfirm --needed)
        rm -rf /tmp/paru
        echo "paru has been installed successfully."
    else
        echo "paru is already installed. Skipping installation."
    fi
}

#
# Installs packages from the official repositories and the AUR using paru.
#
install_packages_with_paru() {
    echo "--> Installing all user packages with paru..."
    # Paru will install packages from both official repos and the AUR.
    # It will handle its own sudo prompt when needed for pacman operations.
    paru -S --noconfirm --needed "${PACKAGES_TO_INSTALL[@]}"
}

#
# Prevents the official Dropbox client from auto-updating itself, which can
# cause issues. It achieves this by creating a root-owned placeholder directory.
#
configure_dropbox() {
    echo "--> Configuring Dropbox to prevent automatic updates..."
    # A password prompt is expected here, as this is the one command that
    # requires root privileges to create a root-owned directory.
    sudo install -dm0 "$USER_HOME/.dropbox-dist"
    echo "Dropbox update prevention configured."
}

#
# Clones the Oh My Zsh repository for Zsh configuration.
#
install_oh_my_zsh() {
    echo "--> Installing Oh My Zsh..."
    # Only install if the user's shell is Zsh and OMZ is not already installed.
    if [[ "$SHELL" == "/bin/zsh" || "$SHELL" == "/usr/bin/zsh" ]]; then
        if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
            git clone https://github.com/ohmyzsh/ohmyzsh.git "$USER_HOME/.oh-my-zsh"
            echo "Oh My Zsh has been cloned."
        else
            echo "Oh My Zsh directory already exists. Skipping clone."
        fi
    else
        echo "Warning: Shell is not Zsh. Skipping Oh My Zsh installation."
    fi
}

#
# Installs the Bun JavaScript runtime using its official installer script.
#
install_bun() {
    echo "--> Installing Bun JavaScript runtime..."
    if [ ! -f "$USER_HOME/.bun/bin/bun" ]; then
        curl -fsSL https://bun.sh/install | bash
        echo "Bun has been installed."
    else
        echo "Bun appears to be already installed. Skipping."
    fi
}

#
# Enables and starts user-specific systemd services.
#
configure_user_services() {
    echo "--> Enabling user systemd services..."
    systemctl --user enable ssh-agent.service # Enable and start the ssh-agent service for the user.
    echo "User services enabled."
}


# --- Main Execution ---

echo "--- Starting User Environment Setup for '$USERNAME' ---"

# Step 1: Install AUR helper
install_paru

# Step 2: Install all user packages
install_packages_with_paru

# Step 3: Enable user systemd services
configure_user_services

# Step 4: Configure user applications
configure_dropbox
install_oh_my_zsh
install_bun

echo "--- User setup for '$USERNAME' complete! ---"
