# syntax=docker/dockerfile:1
# ---------------------------------------------------------
# snic/devenv-web-terminal — Browser-accessible dev environment via ttyd
#
# Theme: Catppuccin Macchiato (configured in entrypoint.sh)
#
# TODO [ghostty-web migration]:
#   ttyd uses xterm.js for terminal emulation. Once ghostty-web (coder/ghostty-web)
#   reaches v1.0 with stable libghostty-vt WASM support, migrate to ghostty-web
#   for pixel-identical rendering to our Ghostty desktop terminal.
#   Track: https://github.com/coder/ghostty-web
#   Track: https://mitchellh.com/writing/libghostty-is-coming
# ---------------------------------------------------------
ARG DEVENV_TAG=latest

FROM snic/devenv:${DEVENV_TAG}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG IMAGE_VERSION=dev

LABEL org.opencontainers.image.source="https://github.com/snics/dotfiles" \
    org.opencontainers.image.title="snic/devenv-web-terminal" \
    org.opencontainers.image.description="Browser-accessible dev environment via ttyd" \
    org.opencontainers.image.version="${IMAGE_VERSION}"

ARG TARGETARCH
ARG TTYD_VERSION=1.7.7
# SHA256 checksums for ttyd binary (supply-chain integrity)
ARG TTYD_SHA256_AMD64=8a217c968aba172e0dbf3f34447218dc015bc4d5e59bf51db2f2cd12b7be4f55
ARG TTYD_SHA256_ARM64=b38acadd89d1d396a0f5649aa52c539edbad07f4bc7348b27b4f4b7219dd4165

USER root

# Download ttyd binary (static, no archive — just a binary per arch)
RUN ARCH=$([ "${TARGETARCH}" = "arm64" ] && echo "aarch64" || echo "x86_64") \
    && TTYD_SHA256=$([ "${TARGETARCH}" = "arm64" ] && echo "${TTYD_SHA256_ARM64}" || echo "${TTYD_SHA256_AMD64}") \
    && curl -fsSL "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${ARCH}" \
    -o /usr/local/bin/ttyd \
    && echo "${TTYD_SHA256}  /usr/local/bin/ttyd" | sha256sum -c - \
    && chmod +x /usr/local/bin/ttyd

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER developer

# Entry mode: terminal (default), tmux, nvim, or any custom command
ENV TTYD_MODE=terminal

EXPOSE 7681

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:7681/ || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
