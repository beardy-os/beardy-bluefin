ARG BASE_VERSION="41"
ARG BASE_IMAGE="ghcr.io/ublue-os/bluefin"
ARG CACHE_ID_SUFFIX="beardy-bluefin-latest"

FROM scratch AS ctx
COPY / /

FROM ${BASE_IMAGE}:${BASE_VERSION}

ARG FEDORA_MAJOR_VERSION="41"
ARG IMAGE_VENDOR="beardy-os"
ARG IMAGE_NAME="beardy-bluefin"

# Unwrap cli
RUN \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/unwrap-cli.sh && \
    ostree container commit

# Update image info
RUN \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/image-info.sh && \
    ostree container commit

# Add additional packages
RUN \
    --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-${CACHE_ID_SUFFIX},sharing=locked \
    --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-${CACHE_ID_SUFFIX},sharing=locked \
    dnf5 -y install tig qemu-img && \
    ostree container commit

## Final command
RUN bootc container lint
