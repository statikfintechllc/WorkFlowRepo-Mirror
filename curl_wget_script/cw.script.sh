#!bin/bash

set -e

# Change this to your actual tar.gz bundle URL
BOOT_URL="https://githubagon-boot.git"

echo "[🐉] Downloading Dragon Boot Theme Package..."
mkdir -p /tmp/dragon-boot
cd /tmp/dragon-boot

# 🔧 Dependency Check
echo "[🔍] Checking for required packages..."
if command -v apt &>/dev/null; then
    sudo apt update
    sudo apt install -y plymouth plymouth-themes grub2-common
elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm plymouth grub
elif command -v dnf &>/dev/null; then
    sudo dnf install -y plymouth grub2
else
    echo "❌ Unsupported package manager. Install dependencies manually."
    exit 1
fi

# Download and extract
wget -q --show-progress "$BOOT_URL" -O dragon-boot.tar.gz
echo "[📦] Extracting dragon-boot.tar.gz..."
tar -xzf dragon-boot.tar.gz
cd dragon-boot

echo "[🔧] Installing Dragon Boot Theme..."

cd WorkFlowRepo-Mirror
ls
cd .github/workflows
ls
cd .. && cd ..
cd docs
ls
cd ticker-bot
ls && cd ..
cd graph
ls
cd .. && cd ..
