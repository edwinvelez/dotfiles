local mainMod = "SUPER"

-- --- High-Performance Discrete GPU Launcher Binds (PRIME Offload) ---
local primeRun = "env __NV_PRIME_RENDER_OFFLOAD=1 env __GLX_VENDOR_LIBRARY_NAME=nvidia env __VK_LAYER_NV_optimus=NVIDIA_only "

-- Example bind: Launch kitty terminal running explicitly on the discrete GPU
hl.bind("SUPER + SHIFT + RETURN", hl.dsp.exec_cmd(primeRun .. "kitty"))

-- --- Core Application Launchers ---
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprshutdown"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))

-- --- SwayNC Notification Controls ---
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + Grave", hl.dsp.exec_cmd("swaync-client -t -sw"))

-- --- Screenshots (Hyprshot / Local Script) ---
hl.bind("PRINT", hl.dsp.exec_cmd("~/.local/bin/screenshot.sh region"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("~/.local/bin/screenshot.sh window"))
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("~/.local/bin/screenshot.sh output"))

-- Clipboard Only Screenshots
hl.bind("CONTROL + PRINT", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only --post \"notify-send 'Clipboard' 'Area copied'\""))
hl.bind("CONTROL + SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m window --clipboard-only --post \"notify-send 'Clipboard' 'Window copied'\""))

-- --- Focus and Navigation ---
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "previous" }))

-- --- Workspace Navigation and Window Relocation (DRY Loop) ---
for i = 1, 5 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- --- Interactive Mouse Controls ---
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- --- Quake-style Dropdown Terminal (Scratchpad) ---
-- Toggle the scratchpad visibility
hl.bind("ALT + Grave", hl.dsp.exec_cmd("hyprctl dispatch togglespecialworkspace scratchpad"))
-- Move active window to scratchpad
hl.bind("ALT + SHIFT + Grave", hl.dsp.exec_cmd("hyprctl dispatch movetoworkspace special:scratchpad"))
-- Launch a new terminal directly into the scratchpad
hl.bind("SUPER + ALT + Grave", hl.dsp.exec_cmd("hyprctl dispatch exec \"[workspace special:scratchpad] kitty\""))
