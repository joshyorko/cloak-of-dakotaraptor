###############################################################################
# cloak-of-dakotaraptor - Custom Bluefin (Fedora-based)
###############################################################################
# Following the @projectbluefin/finpilot pattern:
# - Base: Bluefin (Fedora Silverblue with Bluefin desktop config)
# - Build: dnf5 for packages, copy files for custom configs
# - Rebaseable from existing Fedora/Bluefin systems
###############################################################################

###############################################################################
# MULTI-STAGE BUILD ARCHITECTURE
###############################################################################
# 1. Context Stage (ctx) - Combines resources from:
#    - Local build scripts and custom files
#    - @projectbluefin/common - Desktop configuration
#    - @ublue-os/brew - Homebrew integration
#
# 2. Base Image: Bluefin (Fedora + GNOME + Bluefin config)
###############################################################################

# Context stage - combine local and imported OCI container resources
FROM scratch AS ctx

COPY build /build
COPY custom /custom
# Copy from OCI containers to distinct subdirectories
COPY --from=ghcr.io/projectbluefin/common:latest /system_files /oci/common
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /oci/brew

# Base Image - Bluefin DX (Developer Experience edition with dev tools)
FROM ghcr.io/ublue-os/bluefin-dx:stable

ARG IMAGE_NAME="${IMAGE_NAME:-cloak-of-dakotaraptor}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-joshyorko}"

### MODIFICATIONS
## Make modifications desired in your image and install packages by modifying the build scripts.
## Scripts are run in numerical order (10-build.sh, 20-example.sh, etc.)

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build/10-build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
