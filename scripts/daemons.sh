#!/usr/bin/env bash

echo "Installing daemons"
pacman -S \
  gufw \
  ufw \
  ufw-extras\
  networkmanager \
  openssh \
  smartmontools \
  --noconfirm --needed

echo "Enabling Uncomplicated Firewall (ufw) daemon"
systemctl enable ufw.service
ufw default deny
ufw enable

echo "Enabling NetworkManager daemon"
systemctl enable NetworkManager.service

echo "Enabling sshd daemon"
systemctl enable sshd.service

echo "Enabling S.M.A.R.T daemon"
systemctl enable smartd.service

echo "Enabling radio device wizard daemon"
systemctl enable NetworkManager-dispatcher.service