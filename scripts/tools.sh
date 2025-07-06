#!/usr/bin/env bash

echo "Installing helpful tools"
pacman -S \
  archlinux-contrib \
  btop \
  curl \
  fastfetch \
  fwupd \
  git \
  gnome-keyring \
  keychain \
  \
  materia-gtk-theme \
  papirus-icon-theme \
  \
  neovim \
  vi \
  \
  pacman-contrib \
  starship \
  stow \
  sudo \
  unzip \
  vim \
  vlc \
  wget \
  xdg-user-dirs \
  xdg-utils \
  xdotool \
  zip \
  zsh \
  zsh-completions \
  --noconfirm --needed
