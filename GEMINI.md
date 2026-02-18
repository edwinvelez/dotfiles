# GEMINI Project Analysis: Dotfiles

This repository implements a **Layered Configuration Architecture** for managing a customized Linux environment across
heterogeneous hardware. It leverages [GNU Stow](https://www.gnu.org/software/stow/) for symlink management, orchestrated
by a Python-based automation layer.

## Architectural Patterns

* **Layered Configuration:** Configurations are split into `common` (universal), `bin` (shared scripts), and
  hardware-specific layers (`desktop`, `laptop`). This ensures DRY (Don't Repeat Yourself) principles across machines.
* **Idempotency:** The setup automation is designed to be executed multiple times without side effects, ensuring the
  target state matches the repository.
* **Single Source of Truth:** All configurations reside in this repository; the `$HOME` directory is treated as a
  projection of this state.

## Directory Structure

* `common/`: Base configurations shared across all environments (Zsh, Hyprland core, Kitty, etc.).
* `bin/`: Local binaries and utility scripts symlinked to `~/.local/bin`.
* `desktop/`: Overrides and additions for high-performance desktop environments (NVIDIA-specific Hyprland configs,
  high-refresh-rate settings).
* `laptop/`: Overrides for mobile environments (Intel GPU drivers, power management, HiDPI scaling).

## Setup and Automation

The environment is managed via `stow-setup.py`.

### Prerequisites

* **GNU Stow:** Required for symlink orchestration.
* **Python 3.x:** Required for the automation script.

### Usage

```bash
# Preview changes (Dry Run)
python3 stow-setup.py --dry-run

# Apply configurations (Auto-detects hardware)
python3 stow-setup.py

# Remove all symlinks (Factory Reset)
python3 stow-setup.py --delete
```

### Automation Logic & Layer Priority

The `stow-setup.py` script applies layers in a deterministic order to handle overrides:

1. **Base Layers (`common/`, `bin/`):** Universal configurations and scripts.
2. **Hardware Layer (`desktop/` or `laptop/`):** Applied last. Files in this layer will override (overwrite the symlink)
   any conflicting paths defined in the base layers.

**Detection Heuristics (in order of priority):**

1. **Explicit Flag:** `--profile [desktop|laptop]`
2. **Systemd Chassis Detection:** Uses `hostnamectl chassis` to identify hardware type.
3. **Hostname Mapping:** Matches system hostname against a predefined map in the script.
4. **Hardware Heuristics:** Detects laptop profile via battery presence (`/sys/class/power_supply/BAT0`).

## Development Conventions

* **Adding Packages:** Create a directory at the root and mirror the internal structure of `$HOME`.
* **Overrides:** To override a `common` config for a specific profile, mirror the file path in the hardware-specific
  directory. Stow handles the link priority during the hardware layer application.
* **Architectural Critique:** Avoid deep nesting in the repository structure. Prefer flat, discoverable package names.
  Ensure all scripts in `bin/` are POSIX-compliant or explicitly specify their runtime requirements.
