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

-- --- Zoom Workplace Lifecycle & Window Management ---
hl.window_rule({
    name = "zoom-share-toolbar",
    match = {
        class = "^(zoom)$",
        title = "^(as_toolbar)$",
    },
    float = true,
    pin = true,
    no_initial_focus = true,
    no_shadow = true,
    rounding = 0,
})

hl.window_rule({
    name = "zoom-share-border",
    match = {
        class = "^(zoom)$",
        title = "^(as_sharing_window)$",
    },
    float = true,
    pin = true,
    no_focus = true,
    no_shadow = true,
    rounding = 0,
})

hl.window_rule({
    name = "zoom-floating-video",
    match = {
        class = "^(zoom)$",
        title = "^(zoom_linux_float_video_window)$",
    },
    float = true,
    pin = true,
    no_initial_focus = true,
})

hl.window_rule({
    name = "zoom-dialogs-and-panels",
    match = {
        class = "^(zoom)$",
        title = "^(Chat|Participant.*|Settings|General|Video|Audio|Share Screen|Breakout Rooms|Polls|Join Meeting|Schedule.*|Notification)$",
    },
    float = true,
    center = true,
})

hl.window_rule({
    name = "zoom-meeting-window",
    match = {
        class = "^(zoom)$",
        title = "^(Zoom Meeting.*|Meeting)$",
    },
    float = true,
})

-- --- Steam & Proton Window Management ---
hl.window_rule({
    name = "steam-main-tile",
    match = {
        class = "^(steam)$",
        title = "^(Steam)$",
    },
    tile = true,
})

hl.window_rule({
    name = "steam-dialogs-float",
    match = {
        class = "^(steam)$",
        title = "^(Friends List|Steam - News|Settings|.*Notification.*)$",
    },
    float = true,
})

hl.window_rule({
    name = "steam-popups-minsize",
    match = { class = "^(steam)$" },
    min_size = "1 1",
})

hl.window_rule({
    name = "steam-games-opaque",
    match = { class = "^(steam_app_.*)$" },
    no_blur = true,
    opaque = true,
    idle_inhibit = "focus",
})

-- --- Picture-in-Picture (Chrome / Firefox video pop-out) ---
-- Floats in the bottom-right corner on every workspace, keeps the video's shape,
-- and never steals focus from what you were doing.
hl.window_rule({
    name = "pip",
    match = { title = "^(Picture[- ]in[- ][Pp]icture)$" },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
    no_initial_focus = true,
    size = "(monitor_w*0.25) (monitor_h*0.25)",
    move = "(monitor_w-window_w-24) (monitor_h-window_h-24)",
})

-- --- File Pickers and Modal Dialogs ---
-- GTK portal (Chrome, Electron, Flatpak) and app-native Open/Save dialogs
-- float centered at a comfortable size instead of tiling half the screen.
hl.window_rule({
    name = "file-dialogs",
    match = { title = "^(Open File.*|Open Folder.*|Save File.*|Save As.*|Select.*|Choose.*|Upload.*|All Files.*)$" },
    float = true,
    center = true,
    size = "(monitor_w*0.5) (monitor_h*0.6)",
})

hl.window_rule({
    name = "portal-dialogs",
    match = { class = "^(xdg-desktop-portal-gtk|org.freedesktop.impl.portal.desktop.gtk|zenity)$" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "modal-dialogs",
    match = { modal = true },
    float = true,
    center = true,
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

-- --- Package Upgrade Terminal (Waybar updates badge, ~/.local/bin/updates) ---
-- Pops up over the current workspace instead of splitting it.
hl.window_rule({
    name = "updates-terminal",
    match = { class = "^(updates)$" },
    float = true,
    center = true,
    size = "(monitor_w*0.6) (monitor_h*0.6)",
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
