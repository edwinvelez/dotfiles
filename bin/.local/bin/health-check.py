#!/usr/bin/env python3
import subprocess
import os
import re

COLORS = {
    "blue": "\033[94m", "green": "\033[92m", 
    "red": "\033[91m", "bold": "\033[1m", "reset": "\033[0m"
}

def run(cmd, include_stderr=False):
    try:
        stderr_setting = subprocess.STDOUT if include_stderr else subprocess.DEVNULL
        return subprocess.check_output(cmd, shell=True, stderr=stderr_setting).decode().strip()
    except: return ""

print(f"\n{COLORS['blue']}{COLORS['bold']}=== STATION HEALTH: EDWIN VELEZ ==={COLORS['reset']}")

# 1. Quick Status (Services & Dropbox)
failed = run("systemctl --failed --quiet | grep 'loaded units'")
db_status = run("dropbox status").split('\n')[0]
if "instance of Dropbox" in db_status: db_status = "Syncing / Running"

print(f"\n{COLORS['blue']}󱄛 SERVICES:{COLORS['reset']} " + ("✔ Clean" if not failed else "✘ Failed Detected"))
print(f"{COLORS['blue']}󰇚 DROPBOX: {COLORS['reset']}" + (f"{COLORS['green']}{db_status}" if "Up to date" in db_status else f"{COLORS['red']}{db_status}") + COLORS['reset'])

# 2. Bun Runtime
bun_v = run("bun --version")
bun_check = run("bun upgrade --dry-run", include_stderr=True)
is_up_to_date = any(x in bun_check.lower() for x in ["already on the latest", "up to date"])
bun_status = f"{COLORS['green']}Up to date{COLORS['reset']}" if is_up_to_date else f"{COLORS['red']}Update Available!{COLORS['reset']}"
print(f"{COLORS['blue']}󰛦 BUN:     {COLORS['reset']} v{bun_v} ({bun_status})")

# 3. Storage & Physical Health (Combined Section)
print(f"\n{COLORS['blue']}{COLORS['bold']}--- DISK HEALTH ---{COLORS['reset']}")
# Btrfs Level
scrub = run("sudo btrfs scrub status / | grep 'Status:'").replace("Status:", "").strip()
print(f"{COLORS['blue']}󰋊 Btrfs (/)  :{COLORS['reset']} {scrub}")

# Physical SMART Level
for disk in ['/dev/nvme0n1', '/dev/sda']:
    smart = run(f"sudo smartctl -H {disk} | grep 'test result'")
    if "PASSED" in smart:
        print(f"{COLORS['blue']}󰋊 Physical {disk[-3:]}:{COLORS['reset']} {COLORS['green']}PASSED{COLORS['reset']}")
    elif smart:
        print(f"{COLORS['blue']}󰋊 Physical {disk[-3:]}:{COLORS['reset']} {COLORS['red']}SMART WARNING!{COLORS['reset']}")
    else:
        print(f"{COLORS['blue']}󰋊 Physical {disk[-3:]}:{COLORS['reset']} {COLORS['blue']}No SMART Support{COLORS['reset']}")

# 4. Critical Logs
kernel_raw = run("sudo journalctl -p 3 -xb --no-pager")
seen, errors = set(), []
for line in kernel_raw.split('\n'):
    if "Process" in line and "dumped core" in line:
        match = re.search(r'Process \d+ \((.*?)\)', line)
        proc_name = match.group(1) if match else "Unknown"
        if proc_name not in seen:
            errors.append(f"{COLORS['red']}󱂬 Crash:{COLORS['reset']} {proc_name}")
            seen.add(proc_name)
    elif "Failed to bind enclosure" in line and "SCSI" not in seen:
        errors.append(f"{COLORS['red']}󰒂 Hardware:{COLORS['reset']} SCSI Error (sda)")
        seen.add("SCSI")

print(f"\n{COLORS['blue']}{COLORS['bold']}--- CRITICAL LOGS ---{COLORS['reset']}")
if not errors: print(f"{COLORS['green']}✔ No critical logs since boot.{COLORS['reset']}")
else:
    for e in errors: print(e)

print(f"\n{COLORS['blue']}==================================={COLORS['reset']}\n")
