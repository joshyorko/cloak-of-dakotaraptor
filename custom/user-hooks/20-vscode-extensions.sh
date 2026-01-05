#!/usr/bin/bash
# Script: 20-vscode-extensions.sh
# Purpose: Install VS Code Insiders extensions on first user login
# Location: /usr/share/ublue-os/user-setup.hooks.d/20-vscode-extensions.sh
# Based on: dudleys-second-bedroom user hooks
#
# This script runs once per user on first login to install extensions
# Uses a marker file to track installation state

set -euo pipefail

# Configuration
EXTENSIONS_LIST="/etc/skel/.config/vscode-extensions.list"
MARKER_FILE="${HOME}/.config/Code - Insiders/.extensions-installed"
MARKER_VERSION="1"

# Logging
log() {
    echo "[vscode-extensions] $*"
}

# Check if VS Code Insiders is installed
if ! command -v code-insiders &>/dev/null; then
    log "VS Code Insiders not found, skipping extension installation"
    exit 0
fi

# Check if extensions list exists
if [[ ! -f "$EXTENSIONS_LIST" ]]; then
    log "Extensions list not found at $EXTENSIONS_LIST, skipping"
    exit 0
fi

# Check marker file
if [[ -f "$MARKER_FILE" ]]; then
    stored_version=$(grep -oP 'version=\K.*' "$MARKER_FILE" 2>/dev/null || echo "0")
    if [[ "$stored_version" == "$MARKER_VERSION" ]]; then
        log "Extensions already installed (version $MARKER_VERSION), skipping"
        exit 0
    fi
    log "Marker version mismatch (stored: $stored_version, current: $MARKER_VERSION), reinstalling"
fi

# Force reinstall if requested
if [[ "${VSCODE_EXTENSIONS_FORCE:-}" == "1" ]]; then
    log "Force reinstall requested"
    rm -f "$MARKER_FILE"
fi

log "Installing VS Code Insiders extensions..."

# Create marker directory
mkdir -p "$(dirname "$MARKER_FILE")"

# Install extensions
installed=0
failed=0
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # Trim whitespace
    extension=$(echo "$line" | xargs)

    log "Installing: $extension"
    if code-insiders --install-extension "$extension" --force 2>/dev/null; then
        ((installed++))
    else
        log "WARNING: Failed to install $extension"
        ((failed++))
    fi
done < "$EXTENSIONS_LIST"

log "Installation complete: $installed succeeded, $failed failed"

# Write marker file
cat > "$MARKER_FILE" <<EOF
version=$MARKER_VERSION
date=$(date -Iseconds)
installed=$installed
failed=$failed
EOF

log "Marker file written to $MARKER_FILE"
