-- --- Cursor Follows New Windows ---
-- With input.follow_mouse = 1, focus tracks the pointer. A new window gets focus when it
-- opens, but the slightest mouse nudge hands focus back to the window under the cursor,
-- so typing lands behind the new window. Warp the cursor onto new windows that took focus.
hl.on("window.open", function(w)
    local address = w.address

    -- Defer briefly so focus and window rules (e.g. no_initial_focus) have settled
    hl.timer(function()
        local active = hl.get_active_window()
        if not active or active.address ~= address then
            return -- the window did not take focus; leave the cursor alone
        end

        local cursor, at, size = hl.get_cursor_pos(), active.at, active.size
        local inside = cursor.x >= at.x and cursor.x < at.x + size.x
            and cursor.y >= at.y and cursor.y < at.y + size.y
        if inside then
            return
        end

        hl.dispatch(hl.dsp.cursor.move({ x = at.x + size.x / 2, y = at.y + size.y / 2 }))
    end, { timeout = 50, type = "oneshot" })
end)
