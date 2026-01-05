# vim: set ft=make :
####################
### custom-apps.just
####################
## Application installation commands for Distroless Bluefin
## Following @projectbluefin/distroless pattern
## See: https://github.com/projectbluefin/distroless

# Install CLI tools and utilities via Homebrew
[group('Brew')]
brews-cli:
    #!/usr/bin/env bash
    echo "Installing CLI tools via Homebrew..."
    brew bundle --file /usr/share/ublue-os/homebrew/default.Brewfile

# Install development tools via Homebrew
[group('Brew')]
brews-dev:
    #!/usr/bin/env bash
    echo "Installing development tools via Homebrew..."
    brew bundle --file /usr/share/ublue-os/homebrew/development.Brewfile

# Install fonts via Homebrew
[group('Brew')]
brews-fonts:
    #!/usr/bin/env bash
    echo "Installing fonts via Homebrew..."
    brew bundle --file /usr/share/ublue-os/homebrew/fonts.Brewfile

# Install Kubernetes and cloud-native tools via Homebrew
[group('Brew')]
brews-k8s:
    #!/usr/bin/env bash
    echo "Installing Kubernetes tools via Homebrew..."
    brew bundle --file /usr/share/ublue-os/homebrew/k8s.Brewfile

# Install all Brewfiles at once
[group('Brew')]
brews-all:
    #!/usr/bin/env bash
    echo "Installing all applications from Brewfiles..."
    brew bundle --file /usr/share/ublue-os/homebrew/default.Brewfile
    brew bundle --file /usr/share/ublue-os/homebrew/development.Brewfile
    brew bundle --file /usr/share/ublue-os/homebrew/fonts.Brewfile
    brew bundle --file /usr/share/ublue-os/homebrew/k8s.Brewfile
    echo "All Brewfiles installed!"

# List available Brewfiles
[group('Brew')]
brews-list:
    #!/usr/bin/env bash
    echo "Available Brewfiles:"
    ls -1 /usr/share/ublue-os/homebrew/*.Brewfile 2>/dev/null | while read f; do
        name=$(basename "$f" .Brewfile)
        echo "  - $name (ujust brews-$name)"
    done

# Install VS Code Insiders (not installed at build time in distroless)
[group('Apps')]
install-vscode-insiders:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Installing VS Code Insiders..."

    # Check if already installed
    if command -v code-insiders &>/dev/null; then
        echo "VS Code Insiders already installed at $(which code-insiders)"
        read -p "Reinstall? [y/N] " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
    fi

    # Download and install
    INSTALL_DIR="${HOME}/.local/share/code-insiders"
    BIN_DIR="${HOME}/.local/bin"

    pushd "$(mktemp -d)" > /dev/null
    echo "Downloading VS Code Insiders..."
    curl -sSfL -o vscode-insiders.tar.gz "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64"

    echo "Extracting to ${INSTALL_DIR}..."
    mkdir -p "${INSTALL_DIR}"
    tar -xzf vscode-insiders.tar.gz -C "${INSTALL_DIR}" --strip-components=1

    echo "Creating symlink..."
    mkdir -p "${BIN_DIR}"
    ln -sf "${INSTALL_DIR}/bin/code-insiders" "${BIN_DIR}/code-insiders"

    popd > /dev/null

    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
        echo "NOTE: Add ${BIN_DIR} to your PATH if not already present"
    fi

    echo "VS Code Insiders installed! Run 'code-insiders' to launch."
    echo "Run 'ujust vscode-extensions' to install extensions."

# Reinstall VS Code Insiders extensions
[group('Apps')]
vscode-extensions:
    #!/usr/bin/env bash
    if ! command -v code-insiders &>/dev/null; then
        echo "VS Code Insiders not installed. Run 'ujust install-vscode-insiders' first."
        exit 1
    fi
    echo "Installing VS Code Insiders extensions..."
    VSCODE_EXTENSIONS_FORCE=1 bash /usr/share/ublue-os/user-setup.hooks.d/20-vscode-extensions.sh

# Install JetBrains Toolbox for managing JetBrains IDEs
[group('Apps')]
install-jetbrains-toolbox:
    #!/usr/bin/env bash
    echo "Installing JetBrains Toolbox..."
    pushd "$(mktemp -d)"
    echo "Fetching latest version..."
    curl -sSfL -o releases.json "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"
    BUILD_VERSION=$(jq -r '.TBA[0].build' ./releases.json)
    DOWNLOAD_LINK=$(jq -r '.TBA[0].downloads.linux.link' ./releases.json)
    CHECKSUM_LINK=$(jq -r '.TBA[0].downloads.linux.checksumLink' ./releases.json)
    echo "Installing JetBrains Toolbox ${BUILD_VERSION}"
    curl -sSfL -O "${DOWNLOAD_LINK}"
    curl -sSfL "${CHECKSUM_LINK}" | sha256sum -c
    tar zxf jetbrains-toolbox-"${BUILD_VERSION}".tar.gz
    mkdir -p $HOME/.local/share/JetBrains/ToolboxApp/
    mv jetbrains-toolbox-"${BUILD_VERSION}"/* $HOME/.local/share/JetBrains/ToolboxApp/
    popd
    echo "Launching JetBrains Toolbox..."
    $HOME/.local/share/JetBrains/ToolboxApp/bin/jetbrains-toolbox

# Shortcut for install-jetbrains-toolbox
[group('Apps')]
jetbrains-toolbox:
    @ujust install-jetbrains-toolbox

# Install a Flatpak application from Flathub
[group('Apps')]
install-flatpak APP_ID:
    #!/usr/bin/bash
    echo "Installing {{ APP_ID }} from Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub {{ APP_ID }}

# Example: Install GIMP via Flatpak
[group('Apps')]
install-gimp:
    ujust install-flatpak org.gimp.GIMP
