local mainMod = "SUPER"

-- Every bind with a description shows up in the SUPER + / cheatsheet
-- (~/.local/bin/keybinds reads them back from `hyprctl binds -j`).
-- opts("Text", { locked = true }) merges extra bind flags with the description.
local function opts(description, extra)
    local o = { description = description }
    for k, v in pairs(extra or {}) do o[k] = v end
    return o
end

-- --- Help ---
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd("keybinds"), opts("Show this keybind cheatsheet"))

-- --- Core Application Launchers ---
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"), opts("Terminal (kitty)"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("google-chrome-stable"), opts("Browser (Chrome)"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"), opts("File manager (Thunar)"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -show drun"), opts("App launcher"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"), opts("Clipboard history"))

-- --- Window & Session State Management ---
hl.bind(mainMod .. " + W", hl.dsp.window.close(), opts("Close window"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.kill(), opts("Force kill window"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(), opts("Toggle fullscreen"))
hl.bind(mainMod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }), opts("Toggle floating"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"), opts("Lock screen"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprshutdown"), opts("Log out (closes apps gracefully)"))

-- --- SwayNC Notification Controls ---
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("swaync-client -t -sw"), opts("Control center"))

-- --- Hardware Controls (Audio, Brightness & Media) ---
-- ~/.local/bin/osd changes the value and shows a progress popup via swaync.
-- locked: works on the lock screen; repeating: holding the key keeps stepping.
local held = { locked = true, repeating = true }
local locked = { locked = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("osd volume up"), opts("Volume up", held))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("osd volume down"), opts("Volume down", held))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("osd volume mute"), opts("Mute speakers", locked))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("osd mic mute"), opts("Mute microphone", locked))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("osd brightness up"), opts("Brightness up", held))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("osd brightness down"), opts("Brightness down", held))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), opts("Play / pause", locked))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), opts("Next track", locked))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), opts("Previous track", locked))

-- --- Screenshots (Native Wayland: grim, slurp, swappy) ---
-- exec_cmd already runs through a shell, so pipes and $(...) work without an sh -c wrapper.
hl.bind("PRINT", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"), opts("Screenshot area → editor"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("grim - | swappy -f -"), opts("Screenshot screen → editor"))
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/Shot_$(date +%Y-%m-%d_%H%M%S).png && notify-send \"Screenshot\" \"Full display saved to ~/Pictures/Screenshots\""), opts("Screenshot screen → file"))
hl.bind("CONTROL + PRINT", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy && notify-send \"Screenshot\" \"Area copied to clipboard\""), opts("Screenshot area → clipboard"))
hl.bind("CONTROL + SHIFT + PRINT", hl.dsp.exec_cmd("grim - | wl-copy && notify-send \"Screenshot\" \"Screen copied to clipboard\""), opts("Screenshot screen → clipboard"))

-- --- Focus and Navigation ---
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), opts("Focus left"))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), opts("Focus right"))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), opts("Focus up"))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), opts("Focus down"))
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "previous" }), opts("Previous workspace"))

-- --- Workspace Navigation and Window Relocation (DRY Loop) ---
-- Only workspace 1 carries a description; the cheatsheet shows it as "1…5".
for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }),
        i == 1 and opts("Switch to workspace 1…5") or nil)
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }),
        i == 1 and opts("Move window to workspace 1…5") or nil)
end

-- --- Interactive Mouse Controls ---
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Drag to move window" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Drag to resize window" })

-- --- Quake-style Dropdown Terminal (Scratchpad) ---
hl.bind("ALT + Grave", hl.dsp.workspace.toggle_special("scratchpad"), opts("Show / hide scratchpad"))
hl.bind("ALT + SHIFT + Grave", hl.dsp.window.move({ workspace = "special:scratchpad" }), opts("Move window to scratchpad"))
hl.bind("SUPER + ALT + Grave", hl.dsp.exec_cmd("kitty", { workspace = "special:scratchpad" }), opts("New terminal in scratchpad"))
