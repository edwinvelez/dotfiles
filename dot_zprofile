# --- Session Environment ---
export EDITOR="nvim"

# --- Path Configuration ---
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$HOME/.local/bin:$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"

# --- SSH Agent ---
# Point to the socket (matches Hyprland execs.conf logic)
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket

# --- SSH Agent Identity ---
if [[ -S "$SSH_AUTH_SOCK" ]]; then
    # Only try to add if the key actually exists on this machine
    if [ -f "$HOME/.ssh/id_ed25519_github" ]; then
        ssh-add -l >| /dev/null || ssh-add ~/.ssh/id_ed25519_github 2>/dev/null
    fi
fi

# --- XDG Data Directories ---
# Initialize with system defaults if unset, then export.
# This ensures Flatpaks and system apps are discoverable without overwriting existing paths.
: ${XDG_DATA_DIRS:=/usr/local/share:/usr/share}
[[ -d "/var/lib/flatpak/exports/share" ]] && XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share"
[[ -d "$HOME/.local/share/flatpak/exports/share" ]] && XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share"
export XDG_DATA_DIRS