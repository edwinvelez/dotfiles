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
    "udisks2" "udiskie" "xdg-user-dirs"

    # --- Security ---
    "ufw"

    # --- Networking & Remote Access ---
    "curl" "networkmanager" "openssh" "wget"

    # --- CLI Tools & Shells ---
    "btop" "chezmoi" "eza" "fastfetch" "fd" "ncdu" "neovim" "ranger" "ripgrep" "starship" "vim" "zsh" "zsh-autosuggestions" "zsh-syntax-highlighting"

    # --- File Systems & Archives ---
    "exfatprogs" "gvfs" "ntfs-3g" "tar" "unzip" "zip"

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
    "hyprland" "hyprland-qt-support" "hyprpaper" "hyprpolkitagent" "xdg-desktop-portal-gtk" "xdg-desktop-portal-hyprland"
    
    # --- Audio Management ---
    "pavucontrol" "pipewire" "pipewire-alsa" "pipewire-jack" "pipewire-pulse" "wireplumber"
    
    # --- Display Manager ---
    "sddm"

    # --- File Management ---
    "thunar" "thunar-archive-plugin" "thunar-volman"

    # --- GUI Components & Toolkits ---
    "dunst" "kitty" "pyqt5" "qt5-wayland" "qt5ct" "qt6-wayland" "qt6ct" "waybar" "wofi"

    # --- Utilities ---
    "grim" "slurp" "wl-clipboard"
)

# --- Desktop Environment: XFCE ---
XFCE_PACKAGES=(
    # --- Core XFCE Components ---
    "xfce4" "xfce4-goodies"
    
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
# Installs the correct CPU microcode package based on the detected hardware vendor.
# This is a critical security and stability update.
#
install_microcode() {
    echo "Detecting CPU vendor for microcode installation..."
    if grep -q "GenuineIntel" /proc/cpuinfo; then
        echo "Intel CPU detected. Installing intel-ucode..."
        pacman -S --noconfirm --needed intel-ucode
    elif grep -q "AuthenticAMD" /proc/cpuinfo; then
        echo "AMD CPU detected. Installing amd-ucode..."
        pacman -S --noconfirm --needed amd-ucode
    else
        echo "Warning: Could not determine CPU vendor. Skipping microcode installation."
    fi
}

#
# Configures the Uncomplicated Firewall (ufw) with secure, sane defaults.
#
configure_firewall() {
    echo "Configuring firewall with default rules..."
    # By default, deny all incoming traffic.
    ufw default deny incoming
    # By default, allow all outgoing traffic.
    ufw default allow outgoing
    # Explicitly allow SSH connections to prevent being locked out of remote servers.
    ufw allow ssh
    # Enable the firewall.
    ufw enable
    echo "Firewall configured. It will be enabled on next boot."
}


#
# Enables essential systemd services to start automatically on boot.
#
configure_services() {
    echo "Enabling core systemd services for next boot..."
    systemctl enable bluetooth.service         # Enables Bluetooth functionality.
    systemctl enable cups.socket               # Enables the CUPS printing service.
    systemctl enable docker.service            # Enables the Docker container engine.
    systemctl enable NetworkManager.service    # Manages network connections.
    systemctl enable reflector.timer           # Periodically updates the mirrorlist for pacman.
    systemctl enable saned.socket              # Enables network scanning services.
    systemctl enable smartd.service            # Monitors hard drive health (S.M.A.R.T.).
    systemctl enable sshd.service              # Enables remote access via SSH.
    systemctl enable udisks2.service           # Manages disk and auto-mounting functionality.
    systemctl enable ufw.service               # Enables the Uncomplicated Firewall.
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
echo "Installing reflector to manage mirrorlists..."
pacman -Syu --noconfirm --needed reflector
configure_reflector

# STEP 2: Install CPU Microcode
install_microcode

# STEP 3: Install Core Packages and Fonts
echo "Updating system and installing all core packages and fonts..."
pacman -Syu --noconfirm --needed "${CORE_PACKAGES[@]}" "${FONTS[@]}"

# STEP 4: Configure Firewall
configure_firewall

# STEP 5: Rebuild Initial Ramdisk
# This is crucial to ensure new kernel modules (NVIDIA, microcode) are in the boot image.
echo "Rebuilding initramfs to include new kernel modules..."
mkinitcpio -P

# STEP 6: Enable Core System Services
configure_services

# STEP 7: Install Desktop Environment
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

# STEP 8: Configure User Account
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
