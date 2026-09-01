#!/usr/bin/env bash
set -euo pipefail

# Redirect standard input back to the interactive terminal
# (Fixes LUKS passphrase prompt when piped from curl)
exec </dev/tty

TARGET_HOST="${1:-vm-test}"
REPO_URL="https://github.com/NicolaiVdS/nixos-config.git"
WORK_DIR="$HOME/nixos-config"

echo "=================================================="
echo " Starting NixOS Installation for host: .#${TARGET_HOST}"
echo "=================================================="

if [ ! -d "$WORK_DIR" ]; then
  echo "==> Cloning nixos-config repository..."
  nix-shell -p git --run "git clone ${REPO_URL} ${WORK_DIR}"
fi
cd "$WORK_DIR"

echo "==> Running Disko partitioner..."
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko -- --mode disko --flake ".#${TARGET_HOST}"

TOTAL_RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
echo "==> Total RAM detected: ${TOTAL_RAM_MB} MB"

if [ "$TOTAL_RAM_MB" -lt 12000 ]; then
  echo "==> RAM is below 12GB. Creating 8GB Btrfs swapfile on /mnt/persist to prevent OOM..."
  sudo mkdir -p /mnt/persist
  sudo btrfs filesystem mkswapfile -s 8g /mnt/persist/swapfile
  sudo swapon /mnt/persist/swapfile
fi

echo "==> Running nixos-install..."
sudo nixos-install --flake ".#${TARGET_HOST}" --no-root-passwd \
  --cores 4 \
  --option extra-substituters "https://hyprland.cachix.org" \
  --option extra-trusted-public-keys "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="

echo "==> Setting password for user 'nicolaivds'..."
sudo nixos-enter --root /mnt -c "passwd nicolaivds"

echo "=================================================="
echo " Installation finished successfully!"
echo " Run: sudo umount -R /mnt && sudo reboot"
echo "=================================================="
