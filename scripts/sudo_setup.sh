#!/bin/bash
#
# sudo_setup.sh - Arch Linux Post-Installation Setup Script
#
# This script is intended to be run on a minimal Arch Linux installation
# immediately after using the 'archinstall' script. It automates the
# installation and configuration of essential packages, drivers, a desktop
# environment, and user-specific settings.
#

# --- Sudo Check ---
# The script must be run as root. This block checks for root privileges
# and re-executes the script with 'sudo' if necessary, preserving the
# original user's environment variables (like SUDO_USER).
if [[ $EUID -ne 0 ]]; then
   echo "This script requires root privileges. Re-running with sudo..."
   sudo --preserve-env "$0" "$@"
   exit
fi

# --- Script Safety ---
# These options make the script more robust and prevent unexpected behavior.
#   -e: Exit immediately if a command exits with a non-zero status.
#   -u: Treat unset variables as an error when substituting.
#   -o pipefail: The return value of a pipeline is the status of the last
#                command to exit with a non-zero status, or zero if no
#                command exited with a non-zero status.
set -e
set -u
set -o pipefail

# --- User Configuration ---
# Determines the non-root user who ran 'sudo'. This is critical for
# configuring the correct user account without hardcoding a username.
if [ -z "${SUDO_USER-}" ]; then
    echo "Error: Could not determine the original user from \$SUDO_USER." >&2
    echo "This script must be run with 'sudo' by a standard user." >&2
    exit 1
fi
USERNAME="$SUDO_USER"

# Define the user's new default shell.
NEW_SHELL="/bin/zsh"

# --- Package Lists ---

# --- Core System Packages ---
CORE_PACKAGES=(
    # --- Development & Build Tools ---
    "base-devel" "git"

    # --- System Utilities & Management ---
    "efibootmgr" "less" "linux" "linux-headers" "man-db" "man-pages" "smartmontools"
    "udisks2" "xdg-user-dirs"

    # --- Networking & Remote Access ---
    "curl" "networkmanager" "openssh" "wget"

    # --- CLI Tools & Shells ---
    "btop" "chezmoi" "eza" "fastfetch" "fd" "neovim" "ripgrep" "starship" "vim" "zsh"

    # --- File Systems & Archives ---
    "exfatprogs" "ntfs-3g" "tar" "unzip" "zip"

    # --- NVIDIA Graphics Drivers ---
    "libva-nvidia-driver" "linux-firmware-nvidia" "nvidia-dkms" "nvidia-settings" "nvidia-utils"
    
    # --- System Services ---
    "bluez" "bluez-libs" "bluez-utils" "cups" "hplip" "sane"
    
    # --- GUI Dependencies & Theming ---
    "gnome-keyring" "libnotify" "materia-gtk-theme" "papirus-icon-theme"
    
    # --- Virtualization ---
    "docker" "docker-compose" "virtualbox" "virtualbox-guest-iso" "virtualbox-host-dkms"
)

# --- Desktop Environment: Hyprland ---
HYPRLAND_PACKAGES=(
    # --- Core Hyprland Components ---
    "hyprland" "hyprpaper" "hyprpolkitagent" "xdg-desktop-portal-hyprland"
    
    # --- Audio Management ---
    "pavucontrol" "pipewire" "pipewire-alsa" "pipewire-jack" "pipewire-pulse"
    
    # --- Display Manager ---
    "sddm"

    # --- GUI Components & Toolkits ---
    "dunst" "kitty" "qt5ct" "qt6ct" "waybar" "wofi"

    # --- Utilities ---
    "grim" "slurp" "wl-clipboard"
)

# --- Desktop Environment: XFCE ---
XFCE_PACKAGES=(
    # --- Core XFCE Components ---
    "thunar" "xfce4" "xfce4-goodies"
    
    # --- Display Manager ---
    "lightdm" "lightdm-gtk-greeter"
)

# --- Font Packages ---
FONTS=(
    "inter-font" "noto-fonts" "noto-fonts-emoji" "ttf-dejavu" "ttf-firacode-nerd"
    "ttf-hack-nerd" "ttf-iosevka-nerd" "ttf-jetbrains-mono-nerd" "ttf-liberation" "ttf-roboto"
)

# --- Functions ---

#
# Configures reflector to find the fastest and most up-to-date Arch Linux mirrors.
# This function creates a configuration file and runs reflector immediately
# to speed up the subsequent package installations.
#
configure_reflector() {
    echo "Configuring reflector to select the best mirrors..."
    cat > /etc/reflector.conf << EOF
# Reflector configuration for the systemd service and initial run.
--save /etc/pacman.d/mirrorlist
--protocol https
--country US
--latest 10
--sort rate
--age 12
EOF
    # Run reflector immediately using the new configuration.
    reflector --verbose @/etc/reflector.conf
    echo "Reflector configuration complete and mirrorlist updated."
}

#
# Enables essential systemd services to start automatically on boot.
#
configure_services() {
    echo "Enabling core systemd services for next boot..."
    systemctl enable bluetooth.service
    systemctl enable cups.socket
    systemctl enable docker.service
    systemctl enable NetworkManager.service
    systemctl enable reflector.timer # This will keep the mirrorlist updated weekly.
    systemctl enable saned.socket
    systemctl enable smartd.service
    systemctl enable sshd.service
    systemctl enable udisks2.service
    echo "Core services enabled."
}

#
# Prompts the user to choose a desktop environment and sets the relevant
# package list variables for installation.
#
prompt_de_choice() {
    local choice
    while true; do
        echo "Choose a Desktop Environment to install:"
        echo "1. Hyprland"
        echo "2. XFCE"
        echo "Q. Quit (no DE will be installed)"
        read -p "Enter your choice (1, 2, or Q): " choice
        case "${choice,,}" in
            1) DE_PACKAGES=("${HYPRLAND_PACKAGES[@]}"); DE_NAME="hyprland"; break ;;
            2) DE_PACKAGES=("${XFCE_PACKAGES[@]}"); DE_NAME="xfce"; break ;;
            q) DE_PACKAGES=(); DE_NAME="none"; break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

# --- Main Execution ---

echo "--- Starting Arch Linux Post-Install Setup ---"

# STEP 1: Install Reflector and Configure Mirrors
# Reflector must be installed before it can be configured and run.
echo "Installing reflector to manage mirrorlists..."
pacman -Syu --noconfirm --needed reflector
configure_reflector

# STEP 2: Install Core Packages and Fonts
echo "Updating system and installing all core packages and fonts..."
pacman -Syu --noconfirm --needed "${CORE_PACKAGES[@]}" "${FONTS[@]}"

# STEP 3: Rebuild Initial Ramdisk
# This is crucial to ensure that new kernel modules, especially the NVIDIA
# drivers, are included in the boot image.
echo "Rebuilding initramfs to include new kernel modules..."
mkinitcpio -P

# STEP 4: Enable Core System Services
configure_services

# STEP 5: Install Desktop Environment
prompt_de_choice

if [ ${#DE_PACKAGES[@]} -gt 0 ]; then
    echo "Installing packages for the '$DE_NAME' desktop environment..."
    pacman -S --noconfirm --needed "${DE_PACKAGES[@]}"

    echo "Enabling and configuring the Display Manager..."
    if [[ "$DE_NAME" == "hyprland" ]]; then
        systemctl enable sddm.service
        echo "sddm enabled."
    elif [[ "$DE_NAME" == "xfce" ]]; then
        systemctl enable lightdm.service
        # Configure LightDM to use the GTK greeter.
        sed -i 's/^#greeter-session=.*/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf
        echo "lightdm enabled and configured."
    fi
fi

# STEP 6: Configure User Account
echo "Configuring user account for '$USERNAME'..."

# Add the user to essential groups for docker and virtualization.
usermod -aG docker,vboxusers "$USERNAME"
# Change the user's default shell to zsh.
usermod --shell "$NEW_SHELL" "$USERNAME"

# Prompt for an optional friendly name (full name).
read -p "Please enter your full name (e.g., Edwin Velez). Press Enter to skip: " FRIENDLY_NAME
if [[ -n "$FRIENDLY_NAME" ]]; then
    chfn -f "$FRIENDLY_NAME" "$USERNAME"
    echo "Friendly name set for '$USERNAME'."
else
    echo "Skipping friendly name setup."
fi

echo "--- Setup Complete! Please reboot your system for all changes to take effect. ---"
