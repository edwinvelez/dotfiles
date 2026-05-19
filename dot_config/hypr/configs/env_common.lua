-- --- Toolkit Backends (Native Wayland) ---
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

-- --- Qt Theming ---
hl.env("QT_QPA_PLATFORMTHEME", "hyprqt6engine")
hl.env("QT_STYLE_OVERRIDE", "Fusion")
hl.env("QT_PASSWORD_STORE", "gnome-libsecret")
hl.env("PASSWORD_STORE_SET", "gnome-libsecret")

-- --- Font Rendering ---
hl.env("XFT_ANTIALIAS", "true")
hl.env("XFT_HINTING", "slight")
hl.env("XFT_HINTSTYLE", "hintslight")
hl.env("XFT_RGBA", "rgb")

-- --- Cursor & Screenshots ---
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRSHOT_DIR", "$HOME/Pictures/Screenshots")

-- --- SSH Agent Socket ---
hl.env("SSH_AUTH_SOCK", "$XDG_RUNTIME_DIR/ssh-agent.socket")
