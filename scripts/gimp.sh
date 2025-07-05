#!/usr/bin/env bash

echo "Installing Gimp"
pacman -S \
  gimp \
  xsane \
  xsane-gimp \
  --noconfirm --needed
