#!/usr/bin/env bash

echo "Installing Intel video drivers"

pacman -S \
  mesa \
  --noconfirm --needed
