#!/usr/bin/env bash

echo "Installing printer packages"
pacman -S \
  cups \
  hplip \
  pyqt5 \
  --noconfirm --needed

echo "Enabling printing services daemon"
systemctl enable cups.service