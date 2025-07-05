#!/usr/bin/env bash

echo "Installing VirtualBox"
pacman -S \
  virtualbox \
  virtualbox-host-modules-arch \
  virtualbox-guest-iso \
  --noconfirm --needed

echo "Adding user to vboxusers group"
usermod -aG vboxusers $USER

echo "Installing VirtualBox extensions"
paru -S virtualbox-ext-oracle --noconfirm --needed
