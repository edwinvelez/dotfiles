#!/usr/bin/env bash

echo "Installing fonts"
pacman -S \
  gnu-free-fonts \
  inter-font \
  noto-fonts \
  noto-fonts-emoji \
  noto-fonts-extra \
  otf-hermit \
  otf-libertinus \
  otf-montserrat \
  terminus-font \
  ttf-bitstream-vera \
  ttf-caladea \
  ttf-carlito \
  ttf-croscore \
  ttf-dejavu \
  ttf-droid \
  \
  ttf-fira-code \
  ttf-firacode-nerd \
  ttf-fira-mono \
  otf-fira-mono \
  \
  ttf-font-awesome \
  ttf-hack \
  ttf-ibm-plex \
  ttf-inconsolata \
  ttf-liberation \
  ttf-opensans \
  ttf-roboto \
  ttf-ubuntu-font-family \
  --noconfirm --needed
