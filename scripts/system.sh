#!/usr/bin/env bash

echo "Installing system packages"
pacman -S \
  base \
  base-devel \
  linux \
  linux-headers \
  linux-lts \
  linux-lts-headers \
  linux-firmware \
  --noconfirm --needed