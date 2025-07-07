#!/usr/bin/env bash

echo "Installing AUR packages"
paru -S \
  dropbox \
  python-gpgme \
  thunar-dropbox \
  \
  google-chrome \
  visual-studio-code-bin \
  zoom \
  --noconfirm --needed --sudoloop

# https://wiki.archlinux.org/title/Dropbox#Prevent_automatic_updates
rm -rf ~/.dropbox-dist
install -dm0 ~/.dropbox-dist
