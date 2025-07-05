#!/usr/bin/env bash

echo "Installing NVIDIA video drivers"
pacman -S \
  nvidia-dkms \
  nvidia-settings \
  nvidia-utils \
  --noconfirm --needed