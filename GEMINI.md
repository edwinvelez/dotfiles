# GEMINI Project Analysis: Dotfiles

This document provides an overview of this dotfiles repository, its structure, and how to manage the configurations.

## Project Overview

This is a personal dotfiles repository for managing a customized Linux environment. It uses GNU Stow to symlink configuration files into the user's home directory. The repository is structured to support multiple machine profiles, allowing for different configurations on different hardware (e.g., a desktop and a laptop).

The primary components of the managed environment include:

*   **Window Manager:** [Hyprland](https://hyprland.org/) (a dynamic tiling Wayland compositor)
*   **Shell:** Zsh (`.zshrc`)
*   **Terminal:** Kitty (`kitty.conf`)
*   **Application Launcher/Bar:** Waybar
*   **Notification Daemon:** Dunst
*   **File Manager:** Ranger
*   **Editor:** VSCode
*   **Git:** Global `.gitconfig`

## Directory Structure and Profiles

The repository is organized into profiles to tailor configurations for specific machines:

*   `common/`: Contains the base configuration files that are shared across all machines.
*   `bin/`: Contains executable scripts and binaries that should be available in the user's `$PATH`.
*   `desktop/`: Contains configuration files specific to the user's desktop machine. This profile is set up for an NVIDIA GPU.
*   `laptop/`: Contains configuration files specific to the user's laptop. This profile is configured for an Intel GPU and handles high-DPI scaling.

## Setup and Usage

The configurations are deployed using the `stow-setup.sh` script.

**To deploy the dotfiles:**

1.  Clone the repository to your home directory.
2.  Make sure GNU Stow is installed on your system.
3.  Run the setup script:
    ```bash
    ./stow-setup.sh
    ```

The script performs the following actions:
*   It identifies the machine's hostname.
*   It always deploys the `common` and `bin` directories.
*   It deploys either the `desktop` or `laptop` directory based on the hostname. If the hostname is not recognized, it defaults to the `laptop` profile.
*   It uses `stow -vt ~ <directory>` to create symlinks from the repository to the home directory (`~`).

## Development Conventions

*   **Adding New Shared Configurations:** Place new configuration files in the `common` directory in a path that mirrors their intended location in the home directory.
*   **Adding Machine-Specific Configurations:** Add new files to the appropriate profile directory (`desktop` or `laptop`). If a configuration needs to override a file from the `common` directory, place it in the machine-specific directory with the same path. Stow will handle the symlinking priority.
*   **Custom Scripts:** Place custom scripts in the `bin/.local/bin` directory to make them available in the shell's path.
*   **Hostname Configuration:** The `stow-setup.sh` script uses hostnames (`my-desktop`, `my-laptop`) to determine which profile to deploy. You may need to update these hostnames in the script to match your machines.
