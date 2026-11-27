# Dotfiles: Declarative Arch Linux Environment

Declarative, templated configuration management and system provisioning architecture for Arch Linux environments across heterogeneous hardware using [chezmoi](https://www.chezmoi.io/) and modular Lua orchestration for [Hyprland](https://hyprland.org/).

---

## Architectural Principles

- **Single Source of Truth (SSOT):** The repository defines canonical configuration state; live filesystem paths in `$HOME` act strictly as materialized projections.
- **Declarative Templating (DRY):** Dynamic attributes (hostnames, monitor scaling, GPU driver environments) evaluate at runtime via Go templates (`.tmpl`).
- **Idempotency:** System provisioning scripts and configuration rollouts can execute repeatedly without side effects or divergent states.
- **Modular Desktop Subsystems:** Hyprland configurations run on modular Lua execution contexts (`hyprland.lua.tmpl` and `configs/*.lua`) rather than monolithic configuration files.

---

## Repository Topology

```text
.
├── .chezmoi.toml.tmpl         # Master configuration template & chassis detection
├── .chezmoidata/theme.toml    # Shared colour palette, read by every themed template
├── .chezmoitemplates/         # Shared template fragments (e.g. GTK colours)
├── .chezmoiscripts/           # run_onchange scripts (gsettings, lock-screen avatar, wallpaper)
├── .chezmoiignore             # Transient cache and local state exclusion rules
├── .chezmoiremove             # Targets deleted from $HOME after their source is removed
├── dot_config/                # Managed XDG_CONFIG_HOME projections
│   ├── btop/                 # System resource monitoring
│   ├── fontconfig/           # Font rendering (antialias, hinting, subpixel)
│   ├── dockur-windows/       # On-demand Windows 11 VM (Docker Compose)
│   ├── gtk-3.0/, gtk-4.0/    # GTK styling declarations
│   ├── hypr/                 # Modular Lua Hyprland suite, hyprlock, hypridle, hyprsunset
│   ├── kitty/                # Terminal emulator styling and keybinds
│   ├── qt6ct/                # Qt6 configuration and engine styling
│   ├── rofi/                 # Launcher, clipboard and cheatsheet menus
│   ├── swaync/               # Notification center and control panel
│   ├── waybar/               # Dynamic status bar templates
│   └── xsettingsd/           # Theme, cursor and font settings for XWayland apps
├── dot_local/bin/             # User space operational utilities
│   ├── executable_keybinds   # SUPER + / cheatsheet, read live from Hyprland
│   ├── executable_osd        # Volume / mic / brightness popups via SwayNC
│   ├── executable_record     # Screen recording toggle (wf-recorder)
│   ├── executable_screenshot # Print-key screenshots: edit / copy / save, OCR text
│   ├── executable_nightlight # SUPER + N night light override (hyprsunset)
│   ├── executable_clipboard  # SUPER + V history with image thumbnails (cliphist)
│   ├── executable_battery-notify # Laptop low-battery popups (20% / 10%)
│   ├── executable_updates    # Waybar pending-updates badge; click runs paru
│   └── executable_launch-windows.sh # Boots the Windows VM and attaches FreeRDP
├── setup/                     # Bare-metal system provisioning framework
│   ├── install.sh            # Paru, systemd, and Btrfs provisioning script
│   ├── *-removed.txt         # Packages / units install.sh removes on every machine
│   ├── docker-daemon.json    # Docker engine config (data-root, logging)
│   ├── packages-*.txt        # Common and profile-specific package manifests
│   ├── services-*.txt        # Common and profile-specific systemd units
│   └── user-services-*.txt   # systemd --user units (e.g. ssh-agent.socket)
├── dot_zshrc, dot_zprofile    # Zsh interactive shell and environment configuration
└── dot_gitconfig.tmpl         # Global Git configuration template
```

---

## Hardware Profiles

Chassis and hardware detection evaluates dynamically via `hostnamectl chassis` and hostname identification within `.chezmoi.toml.tmpl`.

### Desktop Profile (`my-desktop`)

- **Compute:** AMD Ryzen 7 2700X
- **Graphics:** NVIDIA GeForce GTX 1060 (DKMS driver, hardware video acceleration via `libva-nvidia-driver`)
- **Display:** 4K at 60Hz over HDMI, 1.5x scaling
- **Power:** Never suspends on idle; locks after 10 minutes, screen off after 15

### Laptop Profile (`my-laptop`)

- **Model:** Dell XPS 15 9500
- **Compute:** Intel Core i9-10885H
- **Graphics:** Intel UHD + NVIDIA GeForce GTX 1650 Ti (hybrid, `nvidia-prime`)
- **Display:** 3840x2400 panel at 1.67x scaling
- **Power:** `power-profiles-daemon`; dims at 2.5 min, locks at 5, suspends at 20 on battery only
- **Peripherals:** Touchpad tap-to-click and 3-finger gestures (traditional scroll direction)

---

## Provisioning & Deployment Protocol

### Initial Host Provisioning

Execute the system installer on a fresh Arch Linux installation to deploy package manifests, configure systemd services, apply Btrfs attributes, and link dotfiles:

```bash
# Clone or place dotfiles into target source directory
git clone git@github.com:edwinvelez/dotfiles.git ~/.local/share/chezmoi

# Run dry-run inspection to verify manifest resolution
~/.local/share/chezmoi/setup/install.sh --dry-run

# Execute full automated system provisioning
~/.local/share/chezmoi/setup/install.sh --auto
```

### Manifest Structure

Package and service manifests reside in `setup/` and follow strict categorization:

- `packages-common.txt`: Shared core utilities, base system libraries, and desktop components.
- `packages-desktop.txt`: AMD microcode, NVIDIA drivers, and CUDA/VAAPI support libraries.
- `packages-laptop.txt`: Intel microcode and VAAPI driver, hybrid NVIDIA drivers, and power management.
- `services-*.txt`: Associated `systemd` units enabled and started automatically.
- `user-services-*.txt`: `systemd --user` units enabled for the invoking user.

---

## Operational Workflows

### Configuration Synchronization

Shell functions defined in `dot_zshrc`:

```bash
# Pull the repo, apply it, and hot-reload Hyprland, hypridle, Waybar and SwayNC
dotfiles-sync

# Full maintenance: packages (paru), runtimes (omz, fnm, bun), the claude and agy CLIs,
# dotfiles-sync,
# then install any packages newly added to the setup/ manifests
update-all
```

`update-all` syncs packages with `setup/install.sh --packages-only`, so a change made on one
machine reaches the other on its next `update-all`:

- **Added** to `setup/packages-*.txt`: installed.
- **Removed**: list it in `setup/packages-removed.txt` (and its units in `services-removed.txt` /
  `user-services-removed.txt`). Those units are disabled, then the packages are uninstalled with
  `pacman -Rns`, which asks first. A unit file chezmoi shipped also goes in `.chezmoiremove`.

Enabling newly added services still needs a full `setup/install.sh` run (idempotent; use
`--dry-run` first).

### Standard Chezmoi Operations

```bash
# Preview uncommitted diff against managed targets
chezmoi diff

# Apply changes directly to $HOME
chezmoi apply

# Incorporate manual target edits back into managed source
chezmoi re-add
```

---

## Development Conventions

- **Template Naming:** Any file requiring dynamic variable evaluation must use the `.tmpl` suffix.
- **Lua Environment Scoping:** Hyprland ships Lua stubs at `/usr/share/hypr/stubs/hl.meta.lua`; the repo-root `.luarc.json` points LuaLS-compatible editors at them for `hl.*` completion (plain `.lua` files only; `.lua.tmpl` templates are not valid Lua until rendered).
- **Secret Management:** Secrets must not be committed in plaintext; use `chezmoi age` or external secret managers for sensitive credentials.
