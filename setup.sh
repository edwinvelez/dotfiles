#!/usr/bin/env bash

echo "Synchronizing pacman database"
pacman -Syy

echo "Sourcing setup scripts"
source ./scripts/reflector.sh
source ./scripts/system.sh
source ./scripts/daemons.sh
source ./scripts/nvidia.sh
source ./scripts/tools.sh
source ./scripts/audio-bluetooth.sh
source ./scripts/printing.sh
source ./scripts/fonts.sh