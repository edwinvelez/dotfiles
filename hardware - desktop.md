System:
  Kernel: 7.2.6-zen2-1-zen arch: x86_64 bits: 64
  Desktop: Hyprland v: 0.56.2 Distro: Arch Linux
Machine:
  Type: Desktop Mobo: ASRock model: X470 Taichi serial: <superuser required>
    Firmware: UEFI vendor: American Megatrends v: P10.10 date: 10/25/2023
CPU:
  Info: 8-core model: AMD Ryzen 7 2700X bits: 64 type: MT MCP cache: L2: 4 MiB
  Speed (MHz): avg: 2755 min/max: 2200/4350 cores: 1: 2755 2: 2755 3: 2755
    4: 2755 5: 2755 6: 2755 7: 2755 8: 2755 9: 2755 10: 2755 11: 2755 12: 2755
    13: 2755 14: 2755 15: 2755 16: 2755
Graphics:
  Device-1: NVIDIA GP106 [GeForce GTX 1060 6GB] driver: nvidia v: 580.178.04
  Device-2: Logitech HD Pro Webcam C920 driver: snd-usb-audio,uvcvideo
    type: USB
  Display: wayland server: X.org v: 1.21.1.24 with: Xwayland v: 24.1.13
    compositor: Hyprland v: 0.56.2 driver: X: loaded: nvidia
    unloaded: modesetting gpu: nvidia,nvidia-nvswitch
    resolution: no compositor data resolution: 3840x2160
  API: EGL v: 1.5 drivers: nvidia,swrast
    platforms: gbm,wayland,x11,surfaceless,device
  API: OpenGL v: 4.6.0 compat-v: 4.6 vendor: nvidia mesa v: 580.178.04
    renderer: NVIDIA GeForce GTX 1060 6GB/PCIe/SSE2
  Info: Tools: api: eglinfo,glxinfo gpu: nvidia-smi x11: xprop
Audio:
  Device-1: NVIDIA GP106 High Definition Audio driver: snd_hda_intel
  Device-2: Advanced Micro Devices [AMD] Family 17h HD Audio
    driver: snd_hda_intel
  Device-3: Logitech HD Pro Webcam C920 driver: snd-usb-audio,uvcvideo
    type: USB
  API: ALSA v: k7.2.6-zen2-1-zen status: kernel-api
  Server-1: PipeWire v: 1.6.8 status: active
Network:
  Device-1: Intel Dual Band Wireless-AC 3168NGW [Stone Peak] driver: iwlwifi
  IF: wlp8s0 state: up mac: <filter>
  Device-2: Intel I211 Gigabit Network driver: igb
  IF: enp10s0 state: down mac: <filter>
Bluetooth:
  Device-1: Intel Wireless-AC 3168 Bluetooth driver: btusb type: USB
  Report: btmgmt ID: hci0 state: up address: <filter> bt-v: 4.2
Drives:
  Local Storage: total: 465.76 GiB used: 199.18 GiB (42.8%)
  ID-1: /dev/nvme0n1 vendor: Samsung model: SSD 970 EVO Plus 500GB
    size: 465.76 GiB
Partition:
  ID-1: / size: 46 GiB used: 12.55 GiB (27.3%) fs: btrfs dev: /dev/nvme0n1p2
  ID-2: /boot size: 1022 MiB used: 311.5 MiB (30.5%) fs: vfat
    dev: /dev/nvme0n1p1
  ID-3: /home size: 418.74 GiB used: 186.32 GiB (44.5%) fs: btrfs
    dev: /dev/dm-0
Swap:
  ID-1: swap-1 type: zram size: 4 GiB used: 0 KiB (0.0%) dev: /dev/zram0
Sensors:
  System Temperatures: cpu: 38.1 C mobo: N/A
  Fan Speeds (rpm): N/A
Info:
  Memory: total: 32 GiB available: 31.26 GiB used: 4.25 GiB (13.6%)
  Processes: 406 Uptime: 3d 4h 19m Shell: Bash inxi: 3.3.41
