# =========================
# EDWIN VELEZ - .zshrc 
# =========================

# Point Git and SSH to the socket created in execs.conf
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket

# --- Environment Variables & Paths ---
export ZSH="$HOME/.oh-my-zsh"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export KEYTIMEOUT=1 

# --- Startup Visuals ---
# Fastfetch first so it doesn't push the prompt down after it appears
if command -v fastfetch &> /dev/null; then
    fastfetch
fi

# --- Zsh History ---
export HISTFILE="$HOME/.histfile"
export HISTSIZE=10000
export SAVEHIST=10000
setopt APPEND_HISTORY SHARE_HISTORY INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS HIST_REDUCE_BLANKS HIST_IGNORE_SPACE

# --- Oh My Zsh & Starship ---
ZSH_THEME=""
plugins=(git sudo)

[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# --- Keybindings & Vi Mode ---
bindkey -v
zstyle ':completion:*' menu select
zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' frequency 7    # check every 7 days

# Cursor shape for vi modes (Block for cmd, Beam for insert)
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]]; then
    echo -ne '\e[2 q'
  else
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
echo -ne '\e[5 q' # Initial cursor state

# --- FZF Integration ---
# Enables Ctrl+R history search and file finding
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)
fi

# --- Aliases ---
# Modern CLI Replacements
alias v="nvim"
alias ls="eza --icons --group-directories-first" 
alias ll="eza -lh --icons --group-directories-first"
alias cat="bat"                                  
alias grep='rg'
alias du='ncdu'
alias top='btop'

# Development & Tools
alias ide="jetbrains-toolbox &"
alias py-env="python -m venv .venv && source .venv/bin/activate"
alias check-nocow="lsattr -d ~/Dropbox ~/VirtualBox\ VMs /var/lib/docker"

# System Health Check
alias health="python3 ~/.local/bin/health-check.py"

# --- Functions ---
# Manual Btrfs Snapshot Utility
snap-now() {
    local desc="${1:-Manual_Snapshot_$(date +%Y-%m-%d_%H%M)}"
    echo "Creating Btrfs snapshot: $desc"
    sudo snapper -c root create --description "$desc" --userdata "origin=manual"
    echo "Snapshot created. View with 'snapper list'."
}

# --- SSH Agent Identity ---
if [[ -S "$SSH_AUTH_SOCK" ]]; then
    # Only try to add if the key actually exists on this machine
    if [ -f "$HOME/.ssh/id_ed25519_github" ]; then
        ssh-add -l >| /dev/null || ssh-add ~/.ssh/id_ed25519_github 2>/dev/null
    fi
fi

# --- Plugin Sourcing ---
# Sourced at the end to ensure they don't interfere with custom keybindings
[ -f "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[ -f "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
