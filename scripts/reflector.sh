#!/usr/bin/env bash

echo "Installing reflector"
pacman -S \
  reflector \
  --noconfirm --needed

echo "Updating pacman mirrors"
reflector --verbose --sort rate --age 24 --country US --protocol https --save /etc/pacman.d/mirrorlist