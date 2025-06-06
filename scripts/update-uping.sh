#!/usr/bin/env bash

# Script to update uping module to the latest commit

set -euo pipefail

# Get the latest commit hash from GitHub API
echo "Fetching latest commit hash..."
LATEST_COMMIT=$(curl -s https://api.github.com/repos/xavifr/uping/commits/main | jq -r '.sha')
echo "Latest commit: $LATEST_COMMIT"

# Fetch the tarball and get its hash
echo "Calculating SHA256 hash..."
TARBALL_URL="https://github.com/xavifr/uping/archive/${LATEST_COMMIT}.tar.gz"
SHA256=$(nix-prefetch-url --unpack "$TARBALL_URL")
echo "SHA256: $SHA256"

# Update the uping.nix file (new simplified structure)
echo "Updating modules/home-manager/uping.nix..."
sed -i "s|https://github.com/xavifr/uping/archive/[^\"]*\.tar\.gz|$TARBALL_URL|" modules/home-manager/uping.nix
sed -i "s|sha256 = \"[^\"]*\";|sha256 = \"$SHA256\";|" modules/home-manager/uping.nix

echo "✅ Updated uping module to commit $LATEST_COMMIT"
echo "You can now run: sudo nixos-rebuild switch" 