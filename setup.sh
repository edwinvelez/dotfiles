#!/usr/bin/env bash

echo "Synchronizing pacman database"
pacman -Syy

echo "Installing reflector"
pacman -S \
  reflector \
  --noconfirm --needed

echo "Updating pacman mirrors"
reflector --verbose --sort rate --age 24 --country US --protocol https --save /etc/pacman.d/mirrorlist

echo "Installing tools"
pacman -S \
  fwupd \
  vi \
  zsh \
  --noconfirm --needed

echo "Installing daemons"
pacman -S \
  gufw \
  ufw \
  networkmanager \
  openssh \
  smartmontools \
  --noconfirm --needed

echo "Enabling Uncomplicated Firewall (ufw) daemon"
systemctl enable --now ufw.service
ufw default deny
ufw enable

echo "Enabling NetworkManager daemon"
systemctl enable --now NetworkManager.service

echo "Enabling sshd daemon"
systemctl enable --now sshd.service

echo "Enabling S.M.A.R.T daemon"
systemctl enable --now smartd.service

echo "Enabling radio device wizard daemon"
systemctl enable --now NetworkManager-dispatcher.service

echo "Installing NVIDIA video drivers"
pacman -S \
  nvidia \
  nvidia-lts \
  nvidia-settings \
  nvidia-utils \
  --noconfirm --needed

echo "Installing user tools"
pacman -S \
  btop \
  curl \
  fastfetch \
  git \
  neovim \
  starship \
  stow \
  unzip \
  vim \
  vlc \
  wget \
  xdg-user-dirs \
  xdg-utils \
  xdotool \
  xpdf \
  zip \
  --noconfirm --needed

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

echo "Installing audio support"
pacman -S \
  pipewire \
  pipewire-audio \
  pipewire-pulse \
  wireplumber \
  pavucontrol \
  --noconfirm --needed

echo "Installing bluetooth support"
pacman -S \
  bluez \
  bluez-utils \
  blueman \
  --noconfirm --needed

systemctl enable --now bluetooth.service

echo "Installing printer packages"
pacman -S \
  cups \
  hplip \
  pyqt5 \
  --noconfirm --needed

echo "Enabling printing services daemon"
systemctl enable --now cups.service

echo "Installing Docker"
pacman -S \
  docker \
  docker-compose \
  --noconfirm --needed

echo "Adding user to the docker group."
usermod -aG docker edwinvelez

echo "Enabling Docker socket"
systemctl enable docker.socket