#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Main Build Script - cloak-of-dakotaraptor
###############################################################################
# This script follows the @projectbluefin/finpilot pattern for build scripts.
# Base image: ghcr.io/ublue-os/bluefin:stable (Fedora + GNOME + Bluefin config)
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

IMAGE_NAME="${IMAGE_NAME:-cloak-of-dakotaraptor}"
IMAGE_VENDOR="${IMAGE_VENDOR:-joshyorko}"

echo "::group:: Copy Custom Files"

# Copy Brewfiles to standard location
mkdir -p /usr/share/ublue-os/homebrew/
cp /ctx/custom/brew/*.Brewfile /usr/share/ublue-os/homebrew/ 2>/dev/null || true

# Consolidate Just Files
mkdir -p /usr/share/ublue-os/just/
find /ctx/custom/ujust -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >> /usr/share/ublue-os/just/60-custom.just 2>/dev/null || true

# Copy Flatpak preinstall files
mkdir -p /etc/flatpak/preinstall.d/
cp /ctx/custom/flatpaks/*.preinstall /etc/flatpak/preinstall.d/ 2>/dev/null || true

# Copy VS Code extensions list
if [ -f /ctx/custom/vscode-extensions.list ]; then
    mkdir -p /usr/share/ublue-os/
    cp /ctx/custom/vscode-extensions.list /usr/share/ublue-os/
fi

# Copy user hooks
if [ -d /ctx/custom/user-hooks ]; then
    mkdir -p /usr/share/ublue-os/user-setup.hooks.d/
    for hook in /ctx/custom/user-hooks/*.sh; do
        if [ -f "$hook" ]; then
            cp "$hook" /usr/share/ublue-os/user-setup.hooks.d/
            chmod +x "/usr/share/ublue-os/user-setup.hooks.d/$(basename "$hook")"
        fi
    done
fi

echo "::endgroup::"

echo "::group:: Install Packages"

# Install packages using dnf5
# Example: dnf5 install -y tmux htop

# Example using COPR with isolated pattern:
# copr_install_isolated "ublue-os/staging" package-name

echo "::endgroup::"

echo "::group:: System Configuration"

# Enable/disable systemd services
systemctl enable podman.socket || true

echo "::endgroup::"

echo "::group:: Branding"

# Create image info
IMAGE_REF="ostree-image-signed:docker://ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}"
IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_FLAVOR="main"
IMAGE_TAG="stable"

mkdir -p /usr/share/ublue-os

cat > "$IMAGE_INFO" <<EOF
{
  "image-name": "${IMAGE_NAME}",
  "image-ref": "${IMAGE_REF}",
  "image-flavor": "${IMAGE_FLAVOR}",
  "image-vendor": "${IMAGE_VENDOR}",
  "image-tag": "${IMAGE_TAG}",
  "base-image": "bluefin"
}
EOF

# Optionally customize os-release (commented out - Bluefin branding is preserved)
# If you want custom branding, uncomment and modify:
# cat > /usr/lib/os-release <<EOF
# NAME="Cloak of Dakotaraptor"
# ID="cloak-of-dakotaraptor"
# ID_LIKE="fedora"
# VERSION="${IMAGE_TAG}"
# VERSION_CODENAME="Dakotaraptor"
# PRETTY_NAME="Cloak of Dakotaraptor"
# HOME_URL="https://github.com/joshyorko/cloak-of-dakotaraptor"
# SUPPORT_URL="https://github.com/joshyorko/cloak-of-dakotaraptor/issues"
# BUG_REPORT_URL="https://github.com/joshyorko/cloak-of-dakotaraptor/issues"
# LOGO=fedora-logo-icon
# EOF

echo "::endgroup::"

echo "=== Custom build complete ==="
