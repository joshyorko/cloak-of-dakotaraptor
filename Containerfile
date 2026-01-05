###############################################################################
# cloak-of-dakotaraptor - Distroless Bluefin
###############################################################################
# Following the @projectbluefin/distroless pattern exactly:
# - Base: GNOME OS (gnomeos-nightly) - GNOME already included
# - Layer: @projectbluefin/common - Bluefin desktop config
# - Layer: @ublue-os/brew - Homebrew integration
# - Layer: Local files (extensions, custom configs)
#
# No apt. No dnf. Just copy files. That's the distroless way.
###############################################################################

FROM scratch AS ctx

# Local files (extensions, custom system files)
COPY files /files
# Build helper scripts
COPY build_scripts /build_scripts
# Custom configurations (brew, flatpaks, ujust, user-hooks)
COPY custom /custom
# Bluefin config from OCI containers
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/bluefin /files
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/shared /files
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /files
# Main build script
COPY build.sh /build.sh

# Base Image - GNOME OS (bleeding edge, GNOME included)
FROM quay.io/gnome_infrastructure/gnome-build-meta:gnomeos-nightly

ARG IMAGE_NAME="${IMAGE_NAME:-cloak-of-dakotaraptor}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-kdlocpanda}"

# Build - copy files, setup extensions, configure system
RUN --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=tmpfs,dst=/run \
    --mount=type=bind,from=ctx,source=/,dst=/tmp/ctx \
    /tmp/ctx/build.sh

LABEL containers.bootc=1
LABEL org.opencontainers.image.source="https://github.com/kdlocpanda/cloak-of-dakotaraptor"

RUN bootc container lint
