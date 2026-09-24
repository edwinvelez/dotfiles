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
├── .chezmoiignore             # Transient cache and local state exclusion rules
├── dot_config/                # Managed XDG_CONFIG_HOME projections
│   ├── btop/                 # System resource monitoring
│   ├── gtk-3.0/, gtk-4.0/    # GTK styling declarations
│   ├── hypr/                 # Modular Lua Hyprland suite, hyprlock, hypridle
│   ├── kitty/                # Terminal emulator styling and keybinds
│   ├── qt6ct/                # Qt6 configuration and engine styling
│   ├── swaync/               # Notification center and control panel
│   └── waybar/               # Dynamic status bar templates
├── dot_local/bin/             # User space operational utilities
│   └── executable_dotfiles-sync # Service reload and sync orchestrator
├── setup/                     # Bare-metal system provisioning framework
│   ├── install.sh            # Paru, systemd, and Btrfs provisioning script
│   ├── packages-*.txt        # Common and profile-specific package manifests
│   └── services-*.txt        # Common and profile-specific systemd units
├── dot_zshrc, dot_zprofile    # Zsh interactive shell and environment configuration
└── dot_gitconfig.tmpl         # Global Git configuration template
```

---

## Hardware Profiles

Chassis and hardware detection evaluates dynamically via `hostnamectl chassis` and hostname identification within `.chezmoi.toml.tmpl`.

### Desktop Profile (`my-desktop`)

- **Compute:** AMD Ryzen 7 2700X
- **Graphics:** NVIDIA GeForce GTX 1060 (DKMS driver, hardware video acceleration via `libva-nvidia-driver`)
- **Display:** High-refresh primary display (144Hz) with custom monitor arrangements
- **Power:** Continuous performance state; sleep inhibition for services

### Laptop Profile (`my-laptop`)

- **Compute:** Intel Core i7-8750H
- **Display:** Fractional display scaling (1.25x / 1.5x)
- **Power:** Battery conservation via `tlp` and `thermald`
- **Peripherals:** Touchpad gestures and natural scroll mapping

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
- `packages-laptop.txt`: Intel microcode, power management utilities, and Wi-Fi stack.
- `services-*.txt`: Associated `systemd` units enabled and started automatically.

---

## Operational Workflows

### Configuration Synchronization

Apply configurations and trigger hot-reloads on active window managers and panels:

```bash
# Review pending diff against target filesystem
dotfiles-sync --diff

# Inspect drift status across managed templates
dotfiles-sync --status

# Apply configurations and trigger hot-reloads (Hyprland, Waybar, SwayNC)
dotfiles-sync
```

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
- **Lua Environment Scoping:** Hyprland Lua stubs located at `/usr/share/hypr/stubs/hl.meta.lua` provide type signatures for language servers via `.luarc.json`.
- **Secret Management:** Secrets must not be committed in plaintext; use `chezmoi age` or external secret managers for sensitive credentials.
