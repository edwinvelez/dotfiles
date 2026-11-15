#!/usr/bin/env bash
# Desktop notification for Claude Code hooks (Notification and Stop events).
# Stays quiet when the window running this session is already focused, so it
# only pings you when you've switched away.

input=$(cat)
event=$(jq -r '.hook_event_name // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
project=${cwd##*/}

# Is the focused Hyprland window one of our ancestors (terminal, WebStorm,
# Antigravity)? If so, you're looking at it already.
if command -v hyprctl >/dev/null 2>&1; then
  focused=$(hyprctl activewindow -j 2>/dev/null | jq -r '.pid // empty')
  pid=$$
  while [[ -n $focused && $pid -gt 1 ]]; do
    [[ $pid == "$focused" ]] && exit 0
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    [[ -z $pid ]] && break
  done
fi

case $event in
  Notification)
    msg=$(jq -r '.message // "Claude needs your attention"' <<<"$input")
    notify-send -a "Claude Code" -u normal "Claude · ${project:-session}" "$msg"
    ;;
  Stop)
    notify-send -a "Claude Code" -u low "Claude · ${project:-session}" "Finished — ready for you"
    ;;
esac

exit 0
