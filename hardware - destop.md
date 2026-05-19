System:
  Kernel: 6.18.9-zen1-2-zen arch: x86_64 bits: 64
  Desktop: Hyprland v: 0.53.3 Distro: Arch Linux
Machine:
  Type: Desktop Mobo: ASRock model: X470 Taichi
    serial: <superuser required> Firmware: UEFI
    vendor: American Megatrends v: P10.10
    date: 10/25/2023
CPU:
  Info: 8-core model: AMD Ryzen 7 2700X bits: 64
    type: MT MCP cache: L2: 4 MiB
  Speed (MHz): avg: 2717 min/max: 2200/3700 cores:
    1: 2717 2: 2717 3: 2717 4: 2717 5: 2717 6: 2717
    7: 2717 8: 2717 9: 2717 10: 2717 11: 2717 12: 2717
    13: 2717 14: 2717 15: 2717 16: 2717
Graphics:
  Device-1: NVIDIA GP106 [GeForce GTX 1060 6GB]
    driver: nvidia v: 580.126.09
  Device-2: Logitech HD Pro Webcam C920
    driver: snd-usb-audio,uvcvideo type: USB
  Display: wayland server: X.org v: 1.21.1.21
    with: Xwayland v: 24.1.9 compositor: Hyprland
    v: 0.53.3 driver: X: loaded: nvidia
    unloaded: modesetting gpu: nvidia,nvidia-nvswitch
    resolution: no compositor data
    resolution: 3840x2160
  API: EGL Message: EGL data requires eglinfo.
    Check --recommends.
  Info: Tools: gpu: nvidia-smi x11: xprop
Audio:
  Device-1: NVIDIA GP106 High Definition Audio
    driver: snd_hda_intel
  Device-2: Advanced Micro Devices [AMD] Family 17h
    HD Audio driver: snd_hda_intel
  Device-3: Logitech HD Pro Webcam C920
    driver: snd-usb-audio,uvcvideo type: USB
  API: ALSA v: k6.18.9-zen1-2-zen status: kernel-api
  Server-1: PipeWire v: 1.4.10 status: active
Network:
  Device-1: Intel Dual Band Wireless-AC 3168NGW
    [Stone Peak] driver: iwlwifi
  IF: wlp8s0 state: up mac: <filter>
  Device-2: Intel I211 Gigabit Network driver: igb
  IF: enp10s0 state: down mac: <filter>
Bluetooth:
  Device-1: Intel Wireless-AC 3168 Bluetooth
    driver: btusb type: USB
  Report: btmgmt ID: hci0 state: up address: N/A
Drives:
  Local Storage: total: 465.76 GiB
    used: 77.39 GiB (16.6%)
  ID-1: /dev/nvme0n1 vendor: Samsung
    model: SSD 970 EVO Plus 500GB size: 465.76 GiB
Partition:
  ID-1: / size: 46 GiB used: 9.67 GiB (21.0%)
    fs: btrfs dev: /dev/nvme0n1p2
  ID-2: /boot size: 1022 MiB used: 300.9 MiB (29.4%)
    fs: vfat dev: /dev/nvme0n1p1
  ID-3: /home size: 418.74 GiB
    used: 67.43 GiB (16.1%) fs: btrfs dev: /dev/dm-0
Swap:
  ID-1: swap-1 type: zram size: 4 GiB
    used: 0 KiB (0.0%) dev: /dev/zram0
Sensors:
  System Temperatures: cpu: 44.6 C mobo: N/A
  Fan Speeds (rpm): N/A
Info:
  Memory: total: 32 GiB available: 31.26 GiB
    used: 6.38 GiB (20.4%)
  Processes: 412 Uptime: 1d 4h 9m Shell: Zsh
    inxi: 3.3.40
