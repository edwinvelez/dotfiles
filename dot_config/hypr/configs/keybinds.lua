local mainMod = "SUPER"

-- --- Core Application Launchers ---
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("google-chrome-stable"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"))

-- --- Window & Session State Management ---
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.kill())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprshutdown"))

-- --- SwayNC Notification Controls ---
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + Grave", hl.dsp.exec_cmd("swaync-client -t -sw"))

-- --- Hardware Controls (Audio, Brightness & Media) ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- --- Screenshots (Native Wayland: grim, slurp, swappy) ---
-- Interactive region capture with annotation editor (Swappy)
hl.bind("PRINT", hl.dsp.exec_cmd("sh -c 'grim -g \"$(slurp)\" - | swappy -f -'"))

-- Fullscreen capture with annotation editor
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("sh -c 'grim - | swappy -f -'"))

-- Direct save to ~/Pictures/Screenshots without prompt
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("sh -c 'mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/Shot_$(date +%Y-%m-%d_%H%M%S).png && notify-send \"Screenshot\" \"Full display saved to ~/Pictures/Screenshots\"'"))

-- Clipboard-only captures (Instant, no file stored)
hl.bind("CONTROL + PRINT", hl.dsp.exec_cmd("sh -c 'grim -g \"$(slurp)\" - | wl-copy && notify-send \"Screenshot\" \"Area copied to clipboard\"'"))
hl.bind("CONTROL + SHIFT + PRINT", hl.dsp.exec_cmd("sh -c 'grim - | wl-copy && notify-send \"Screenshot\" \"Screen copied to clipboard\"'"))

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
