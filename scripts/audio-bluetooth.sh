#!/usr/bin/env bash

echo "Installing audio support"
pacman -S \
  pipewire \
  pipewire-audio \
  pipewire-pulse \
  wireplumber \
  pavucontrol \
  --noconfirm --needed

echo "Installing bluetooth support"
pacman -S \
  bluez \
  bluez-utils \
  blueman \
  --noconfirm --needed

systemctl enable bluetooth.service