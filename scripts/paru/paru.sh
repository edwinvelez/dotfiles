#!/usr/bin/env bash

echo "Installing paru"
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm --needed

echo "Cleaning up paru build directory"
cd ..
rm -rf paru