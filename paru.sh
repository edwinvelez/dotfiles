#!/usr/bin/env bash

echo "Installing paru"
pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm --needed

echo "Cleaning up paru build directory"
cd ..
rm -rf paru

echo "Installing google-chrome"
paru -S google-chrome --noconfirm --needed

echo "Installing Visual Studio Code"
paru -S visual-studio-code-bin --noconfirm --needed

echo "Installing Zoom"
paru -S zoom --noconfirm --needed

echo "Installing Dropbox"
paru -S \
  dropbox \
  python-gpgme \
  --noconfirm --needed

# https://wiki.archlinux.org/title/Dropbox#Prevent_automatic_updates
rm -rf ~/.dropbox-dist
install -dm0 ~/.dropbox-dist