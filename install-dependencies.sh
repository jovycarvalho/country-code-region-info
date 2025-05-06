#!/bin/bash

# Install wget, curl, and bats locally (no sudo required)
# Usage: ./install-dependencies.sh

set -euo pipefail

# Local installation directory
LOCAL_BIN="$HOME/.local/bin"
LOCAL_LIB="$HOME/.local/lib"

# Create directories if they don't exist
mkdir -p "$LOCAL_BIN" "$LOCAL_LIB"

# Add ~/.local/bin to PATH if not already present
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo "Adding $LOCAL_BIN to your PATH in ~/.bashrc"
    echo "export PATH=\"\$PATH:$LOCAL_BIN\"" >> "$HOME/.bashrc"
    export PATH="$PATH:$LOCAL_BIN"
fi

# Install wget and curl using apt (if available)
if command -v apt-get &> /dev/null; then
    echo "Installing wget and curl..."
    if ! command -v wget &> /dev/null; then
        apt-get download wget
        ar x wget_*.deb data.tar.xz
        tar -xf data.tar.xz --strip-components=2 -C "$LOCAL_BIN" ./usr/bin/wget
        rm wget_*.deb data.tar.xz
    fi

    if ! command -v curl &> /dev/null; then
        apt-get download curl
        ar x curl_*.deb data.tar.xz
        tar -xf data.tar.xz --strip-components=2 -C "$LOCAL_BIN" ./usr/bin/curl
        rm curl_*.deb data.tar.xz
    fi
else
    echo "Note: apt-get not found. Please install wget and curl manually."
fi

# Install bats-core from GitHub
if ! command -v bats &> /dev/null; then
    echo "Installing bats-core..."
    temp_dir=$(mktemp -d)
    git clone https://github.com/bats-core/bats-core.git "$temp_dir/bats-core"
    "$temp_dir/bats-core/install.sh" "$LOCAL_LIB/bats"
    ln -sf "$LOCAL_LIB/bats/bin/bats" "$LOCAL_BIN/bats"
    rm -rf "$temp_dir"
fi

# Verify installations
echo -e "\nVerifying installations:"
echo -n "wget: "; command -v wget || echo "Not found"
echo -n "curl: "; command -v curl || echo "Not found"
echo -n "bats: "; command -v bats || echo "Not found"

echo -e "\nInstallation complete! You may need to restart your shell or run:"
echo "source ~/.bashrc"