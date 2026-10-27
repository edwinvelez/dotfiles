#!/usr/bin/env bash
# Start the dockur Windows VM on demand and attach via FreeRDP.
set -euo pipefail

compose="$HOME/.config/dockur-windows/compose.yaml"
storage="$HOME/.local/share/docker-volumes/dockur-windows"

fail() {
    notify-send -u critical "Windows VM" "$1"
    exit 1
}

was_running=$(docker inspect -f '{{.State.Running}}' windows 2>/dev/null || echo false)

docker compose -f "$compose" up -d >/dev/null 2>&1 || fail "Failed to start container"

# dockur writes windows.boot once setup completes; until then show the install in the web viewer
if [[ ! -f "$storage/windows.boot" ]]; then
    notify-send "Windows VM" "Installing Windows, this can take a while. Run again once it finishes."
    xdg-open http://127.0.0.1:8006 >/dev/null 2>&1
    exit 0
fi

# Docker's proxy accepts on 3389 before the guest is up, so wait for the boot message instead
if [[ $was_running != true ]]; then
    started=$(docker inspect -f '{{.State.StartedAt}}' windows)
    for ((i = 0; i < 90; i++)); do
        docker logs --since "$started" windows 2>&1 | grep -q "Windows started successfully" && break
        sleep 2
    done
    ((i < 90)) || fail "Timed out waiting for Windows to boot"
    sleep 5 # Give the RDP service a moment after boot
fi

setsid -f xfreerdp3 /v:localhost:3389 /u:edwinvelez /p:edwinvelez /cert:ignore \
    /dynamic-resolution /gfx /network:lan +auto-reconnect \
    +clipboard /sound:sys:pulse >/dev/null 2>&1
