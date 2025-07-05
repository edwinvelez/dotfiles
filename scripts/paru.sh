#!/usr/bin/env bash

echo "Installing paru"
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm --needed

echo "Cleaning up paru build directory"
cd ..
rm -rf paru

echo "Installing AUR packages"
paru -S \
  dropbox \
  python-gpgme \
  thunar-dropbox \
  \
  google-chrome \
  visual-studio-code-bin \
  zoom
  --noconfirm --needed --sudoloop

# https://wiki.archlinux.org/title/Dropbox#Prevent_automatic_updates
rm -rf ~/.dropbox-dist
install -dm0 ~/.dropbox-dist