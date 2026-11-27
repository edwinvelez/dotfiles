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
hl.bind("ALT + TAB", hl.dsp.exec_cmd("pkill -x rofi || rofi -show window"), opts("Window switcher"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("pkill -x rofi || clipboard"), opts("Clipboard history"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("pkill -x rofi || clipboard delete"), opts("Delete clipboard entry"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("rofimoji --action type --skin-tone neutral"), opts("Emoji picker (types it)"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("nightlight"), opts("Toggle night light"))
hl.bind(mainMod .. " + SHIFT + C",hl.dsp.exec_cmd("c=$(hyprpicker -a -f hex) && notify-send --app-name=hyprpicker 'Color copied' \"$c\""), opts("Color picker → clipboard"))

-- --- Window & Session State Management ---
hl.bind(mainMod .. " + W", hl.dsp.window.close(), opts("Close window"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.kill(), opts("Force kill window"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(), opts("Toggle fullscreen"))
hl.bind(mainMod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }), opts("Toggle floating"))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), opts("Flip split (side by side ↔ stacked)"))
-- Pinned floating windows follow you to every workspace (e.g. a video or notes)
hl.bind(mainMod .. " + P", hl.dsp.window.pin(), opts("Pin floating window to all workspaces"))
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

-- --- Screenshots (~/.local/bin/screenshot: grim, slurp, swappy) ---
-- "screen" is the focused monitor; Esc while picking an area cancels.
hl.bind("PRINT", hl.dsp.exec_cmd("screenshot area edit"), opts("Screenshot area → editor"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("screenshot screen edit"), opts("Screenshot screen → editor"))
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("screenshot screen save"), opts("Screenshot screen → file"))
hl.bind("CONTROL + PRINT", hl.dsp.exec_cmd("screenshot area copy"), opts("Screenshot area → clipboard"))
hl.bind("CONTROL + SHIFT + PRINT", hl.dsp.exec_cmd("screenshot screen copy"), opts("Screenshot screen → clipboard"))

-- --- Screen Recording (~/.local/bin/record, wf-recorder) ---
-- Same keys start and stop; a red REC badge shows in Waybar while recording.
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("record"), opts("Record area (again to stop)"))
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("record screen"), opts("Record screen (again to stop)"))

-- --- Focus and Navigation ---
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), opts("Focus left"))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), opts("Focus right"))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), opts("Focus up"))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), opts("Focus down"))
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "previous" }), opts("Previous workspace"))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), opts("Next workspace"))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), opts("Previous workspace (scroll)"))

-- --- Move and Resize (keyboard) ---
-- Move: tiled windows swap places in the layout, floating windows slide over.
-- Resize: hold to keep growing/shrinking (40px per step).
local step = 40
for _, d in ipairs({
    { key = "left",  x = -step, y = 0 },
    { key = "right", x = step,  y = 0 },
    { key = "up",    x = 0,     y = -step },
    { key = "down",  x = 0,     y = step },
}) do
    hl.bind(mainMod .. " + SHIFT + " .. d.key, hl.dsp.window.move({ direction = d.key }), opts("Move window " .. d.key))
    hl.bind(mainMod .. " + CTRL + " .. d.key, hl.dsp.window.resize({ x = d.x, y = d.y, relative = true }),
        opts("Resize window " .. d.key, { repeating = true }))
end

-- --- Workspace Navigation and Window Relocation (DRY Loop) ---
-- Keys 1…9 and 0 map to workspaces 1…10. Only workspace 1 carries a description;
-- the cheatsheet shows it as "1…0".
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }),
        i == 1 and opts("Switch to workspace 1…10") or nil)
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }),
        i == 1 and opts("Move window to workspace 1…10") or nil)
end

-- --- Interactive Mouse Controls ---
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Drag to move window" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Drag to resize window" })

-- --- Quake-style Dropdown Terminal (Scratchpad) ---
hl.bind("ALT + Grave", hl.dsp.workspace.toggle_special("scratchpad"), opts("Show / hide scratchpad"))
hl.bind("ALT + SHIFT + Grave", hl.dsp.window.move({ workspace = "special:scratchpad" }), opts("Move window to scratchpad"))
hl.bind("SUPER + ALT + Grave", hl.dsp.exec_cmd("kitty", { workspace = "special:scratchpad" }), opts("New terminal in scratchpad"))
