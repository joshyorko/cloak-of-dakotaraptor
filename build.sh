#!/usr/bin/env bash
###############################################################################
# build.sh - Distroless Bluefin Build
###############################################################################
# Following @projectbluefin/distroless pattern exactly
###############################################################################

set -xeuo pipefail

# Copy files from context (Bluefin config + local extensions)
cp -avf "/tmp/ctx/files"/. /

# Caffeine extension setup
# The Caffeine extension is built/packaged into a temporary subdirectory.
# It must be moved to the standard extensions directory for GNOME Shell to detect it.
if [ -d /usr/share/gnome-shell/extensions/tmp/caffeine/caffeine@patapon.info ]; then
    mv /usr/share/gnome-shell/extensions/tmp/caffeine/caffeine@patapon.info /usr/share/gnome-shell/extensions/caffeine@patapon.info
fi

# Logo Menu setup
# xdg-terminal-exec is required for this extension
if [ -f /usr/share/gnome-shell/extensions/logomenu@aryan_k/distroshelf-helper ]; then
    install -Dpm0755 -t /usr/bin /usr/share/gnome-shell/extensions/logomenu@aryan_k/distroshelf-helper
fi
if [ -f /usr/share/gnome-shell/extensions/logomenu@aryan_k/missioncenter-helper ]; then
    install -Dpm0755 -t /usr/bin /usr/share/gnome-shell/extensions/logomenu@aryan_k/missioncenter-helper
fi

# GSchema compilation for extensions
for schema_dir in /usr/share/gnome-shell/extensions/*/schemas; do
    if [ -d "${schema_dir}" ]; then
        glib-compile-schemas --strict "${schema_dir}" || true
    fi
done

# Bluefin GSchema overrides - disable extension version validation for gnomeos-nightly
tee /usr/share/glib-2.0/schemas/zz3-bluefin-unsupported-stuff.gschema.override <<EOF
[org.gnome.shell]
disable-extension-version-validation='true'
EOF

# Update background XML month dynamically
# Target both picture-uri and picture-uri-dark
HARDCODED_MONTH="12"
CURRENT_MONTH=$(date +%m)
if [ -f "/usr/share/glib-2.0/schemas/zz0-bluefin-modifications.gschema.override" ]; then
    sed -i "/picture-uri/ s/${HARDCODED_MONTH}/${CURRENT_MONTH}/g" "/usr/share/glib-2.0/schemas/zz0-bluefin-modifications.gschema.override"
fi

# Compile system-wide schemas
rm -f /usr/share/glib-2.0/schemas/gschemas.compiled
glib-compile-schemas /usr/share/glib-2.0/schemas || true

###############################################################################
# Custom files (Brewfiles, Flatpaks, ujust, user-hooks)
###############################################################################

# Copy Brewfiles
if [ -d /tmp/ctx/custom/brew ]; then
    mkdir -p /usr/share/ublue-os/homebrew/
    cp -v /tmp/ctx/custom/brew/*.Brewfile /usr/share/ublue-os/homebrew/ 2>/dev/null || true
fi

# Consolidate Just files
if [ -d /tmp/ctx/custom/ujust ]; then
    mkdir -p /usr/share/ublue-os/just/
    find /tmp/ctx/custom/ujust -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >> /usr/share/ublue-os/just/60-custom.just 2>/dev/null || true
fi

# Copy Flatpak preinstall files
if [ -d /tmp/ctx/custom/flatpaks ]; then
    mkdir -p /usr/etc/flatpak/preinstall.d/
    cp -v /tmp/ctx/custom/flatpaks/*.preinstall /usr/etc/flatpak/preinstall.d/ 2>/dev/null || true
fi

# Copy VS Code extensions list to skeleton
if [ -f /tmp/ctx/custom/vscode-extensions.list ]; then
    mkdir -p /usr/etc/skel/.config/
    cp /tmp/ctx/custom/vscode-extensions.list /usr/etc/skel/.config/
fi

# Copy user hooks
if [ -d /tmp/ctx/custom/user-hooks ]; then
    mkdir -p /usr/share/ublue-os/user-setup.hooks.d/
    for hook in /tmp/ctx/custom/user-hooks/*.sh; do
        [ -f "$hook" ] && cp "$hook" /usr/share/ublue-os/user-setup.hooks.d/ && chmod +x "/usr/share/ublue-os/user-setup.hooks.d/$(basename "$hook")"
    done
fi

###############################################################################
# Branding and services
###############################################################################

# Run branding script
/tmp/ctx/build_scripts/base/branding.sh

# Enable services
systemctl enable brew-setup.service || true

echo "=== Build complete ==="
