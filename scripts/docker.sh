#!/usr/bin/env bash

echo "Installing Docker"
pacman -S \
  docker \
  docker-compose \
  --noconfirm --needed

echo "Adding user to the docker group."
usermod -aG docker $USER

echo "Enabling Docker socket"
systemctl enable docker.socket