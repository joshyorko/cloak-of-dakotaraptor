#!/usr/bin/env bash
###############################################################################
# branding.sh - OS branding and image metadata
###############################################################################
# Creates /usr/lib/os-release and /usr/share/ublue-os/image-info.json
###############################################################################

set -xeuo pipefail

IMAGE_REF="ostree-image-signed:docker://ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}"
IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_FLAVOR="main"
IMAGE_TAG="latest"

mkdir -p /usr/share/ublue-os

cat >$IMAGE_INFO <<EOF
{
  "image-name": "${IMAGE_NAME}",
  "image-ref": "${IMAGE_REF}",
  "image-flavor": "${IMAGE_FLAVOR}",
  "image-vendor": "${IMAGE_VENDOR}",
  "image-tag": "${IMAGE_TAG}"
}
EOF

IMAGE_PRETTY_NAME="Cloak of Dakotaraptor"
HOME_URL="https://github.com/kdlocpanda/cloak-of-dakotaraptor"
DOCUMENTATION_URL="https://github.com/kdlocpanda/cloak-of-dakotaraptor#readme"
SUPPORT_URL="https://github.com/kdlocpanda/cloak-of-dakotaraptor/issues"
BUG_SUPPORT_URL="https://github.com/kdlocpanda/cloak-of-dakotaraptor/issues"
CODE_NAME="Dakotaraptor"
ID="cloak-of-dakotaraptor"

# OS-Release
cat > /usr/lib/os-release <<EOF
NAME="${IMAGE_PRETTY_NAME}"
ID="${ID}"
ID_LIKE="org.gnome.os"
VERSION="${IMAGE_TAG}"
VERSION_CODENAME="${CODE_NAME}"
PRETTY_NAME="${IMAGE_PRETTY_NAME}"
BUG_REPORT_URL="${BUG_SUPPORT_URL}"
HOME_URL="${HOME_URL}"
DOCUMENTATION_URL="${DOCUMENTATION_URL}"
SUPPORT_URL="${SUPPORT_URL}"
LOGO=img-logo-icon
DEFAULT_HOSTNAME="dakotaraptor"
EOF

# Weekly user count for fastfetch (optional - uses Bluefin stats as baseline)
curl --retry 3 --fail https://raw.githubusercontent.com/ublue-os/countme/main/badge-endpoints/bluefin.json 2>/dev/null | jq -r ".message" > /usr/share/ublue-os/fastfetch-user-count || echo "N/A" > /usr/share/ublue-os/fastfetch-user-count

# bazaar weekly downloads used for fastfetch (optional)
curl -X 'GET' --fail \
  'https://flathub.org/api/v2/stats/io.github.kolunmi.Bazaar?all=false&days=1' \
  -H 'accept: application/json' 2>/dev/null | jq -r ".installs_last_7_days" | numfmt --to=si --round=nearest > /usr/share/ublue-os/bazaar-install-count || echo "N/A" > /usr/share/ublue-os/bazaar-install-count

echo "=== Branding complete ==="
