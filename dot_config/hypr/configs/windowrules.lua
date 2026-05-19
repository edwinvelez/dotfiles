-- --- XWayland and Styling Workarounds ---
hl.window_rule({
    name = "xwayland-shadow-and-rounding",
    match = { xwayland = true },
    no_shadow = true,
    rounding = 0,
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
    },
    no_focus = true,
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- --- System Dialogs and Applets (Floating) ---
hl.window_rule({
    name = "pavucontrol-float",
    match = { class = "^(org.pulseaudio.pavucontrol)$" },
    float = true,
})

hl.window_rule({
    name = "nm-connection-editor-float",
    match = { class = "^(nm-connection-editor)$" },
    float = true,
})

hl.window_rule({
    name = "blueman-manager-float",
    match = { class = "^(blueman-manager)$" },
    float = true,
})

hl.window_rule({
    name = "thunar-progress-float",
    match = {
        class = "^(thunar)$",
        title = "^(File Operation Progress)$",
    },
    float = true,
})

hl.window_rule({
    name = "thunar-replace-float",
    match = {
        class = "^(thunar)$",
        title = "^(Confirm to replace files)$",
    },
    float = true,
})

-- --- JetBrains IDE Workarounds ---
hl.window_rule({
    name = "jetbrains-splash",
    match = {
        class = "^(jetbrains-.*)$",
        title = "^(splash)$",
    },
    move = "0 0",
})

hl.window_rule({
    name = "jetbrains-welcome",
    match = {
        class = "^(jetbrains-.*)$",
        title = "^(Welcome.*)$",
    },
    float = true,
})

hl.window_rule({
    name = "jetbrains-win0",
    match = {
        class = "^(jetbrains-.*)$",
        title = "^(win0)$",
    },
    float = true,
})

hl.window_rule({
    name = "jetbrains-operations",
    match = {
        class = "^(jetbrains-.*)$",
        title = "^(Copy|Delete|Move|Rename|Conflict.*)$",
    },
    float = true,
})

-- --- Third-Party Integrations ---
hl.window_rule({
    name = "dropbox-menu",
    match = { class = "^(Dropbox)$" },
    float = true,
})

-- --- Scratchpad Styling ---
hl.window_rule({
    name = "scratchpad-terminal",
    match = { workspace = "name:special:scratchpad" },
    float = true,
    size = "70% 70%",
    center = true,
    animation = "slide",
})

-- --- Layer Rules (Blur for UI Overlays) ---
hl.layer_rule({
    match = { namespace = "rofi" },
    blur = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    match = { namespace = "swaync-control-center" },
    blur = true,
    ignore_alpha = 0.5,
})
