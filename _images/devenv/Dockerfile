# syntax=docker/dockerfile:1
# ---------------------------------------------------------
# snics/devenv — Full CLI + TUI development environment
#
# Multi-stage build:
#   Stage 1 (brew): install CLI tools via Homebrew bottles
#   Stage 2 (final): FROM snics/nvim + shell + TUI tools + configs
#
# Build:  docker build -f _images/devenv/Dockerfile -t snics/devenv .
# Run:    docker run -it --rm -v $(pwd):/home/developer/workspace snics/devenv
# ---------------------------------------------------------
# Pin parent image tag — override with --build-arg NVIM_TAG=<tag> for specific versions
ARG NVIM_TAG=latest

# ============================================================
# Stage 1: Install CLI tools via Homebrew (from split Brewfiles)
# ============================================================
FROM homebrew/brew:4.6.20 AS brew

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    HOMEBREW_NO_ANALYTICS=1 \
    HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1 \
    HOMEBREW_NO_ENV_HINTS=1

# Copy split Brewfiles + exclude list into builder
COPY brew/Brewfile.* brew/docker-exclude /tmp/brew/

# Install all formulae from Brewfiles, excluding macOS-only and oversized packages.
# Steps: 1) extract formula names  2) remove excluded  3) add taps  4) brew install
RUN grep -h '^brew ' /tmp/brew/Brewfile.* | sed 's/brew "\([^"]*\)".*/\1/' | sort -u > /tmp/all_formulae.txt \
    && grep -v '^#' /tmp/brew/docker-exclude | grep -v '^$' > /tmp/excludes.txt \
    && grep -v -F -f /tmp/excludes.txt /tmp/all_formulae.txt > /tmp/install.txt \
    && grep -h '^tap ' /tmp/brew/Brewfile.* | sed 's/tap "\([^"]*\)".*/\1/' | sort -u | while IFS= read -r t; do brew tap "$t" 2>&1 || echo "WARN: tap $t failed"; done \
    && failed="" \
    && while IFS= read -r pkg; do \
    brew install "$pkg" 2>&1 \
    || { echo "RETRY: $pkg (attempt 2)"; sleep 3; brew install "$pkg" 2>&1; } \
    || { echo "RETRY: $pkg (attempt 3)"; sleep 5; brew install "$pkg" 2>&1; } \
    || { echo "FAIL: $pkg"; failed="$failed $pkg"; }; \
    done < /tmp/install.txt \
    && if [ -n "$failed" ]; then echo "==> Packages that failed to install:$failed"; fi \
    && rm -rf /tmp/brew /tmp/*.txt || true

# Trim Homebrew caches and build artifacts to reduce COPY size.
# The entire /home/linuxbrew prefix is kept intact (no patchelf needed)
# so that scripts, Python tools, and complex runtimes all work correctly.
RUN rm -rf /home/linuxbrew/.cache \
    /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/*/homebrew-*/Formula \
    /home/linuxbrew/.linuxbrew/share/doc \
    /home/linuxbrew/.linuxbrew/share/man \
    /home/linuxbrew/.linuxbrew/share/info

# ============================================================
# Stage 2: Final image — snics/nvim + shell + TUI tools
# ============================================================
FROM snics/nvim:${NVIM_TAG}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG IMAGE_VERSION=dev

LABEL org.opencontainers.image.source="https://github.com/snics/dotfiles" \
    org.opencontainers.image.title="snics/devenv" \
    org.opencontainers.image.description="Full CLI + TUI development environment" \
    org.opencontainers.image.version="${IMAGE_VERSION}"

USER root

# System setup: dpkg excludes + shell deps + locale + chsh (one layer)
# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    echo 'path-exclude=/usr/share/doc/*' >> /etc/dpkg/dpkg.cfg.d/excludes \
    && echo 'path-exclude=/usr/share/man/*' >> /etc/dpkg/dpkg.cfg.d/excludes \
    && echo 'path-exclude=/usr/share/locale/*' >> /etc/dpkg/dpkg.cfg.d/excludes \
    && echo 'path-exclude=/usr/share/info/*' >> /etc/dpkg/dpkg.cfg.d/excludes \
    && apt-get update && apt-get install -y --no-install-recommends \
    zsh tmux jq less file locales procps \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && chsh -s /bin/zsh developer

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Copy entire Homebrew prefix from brew stage (scripts, runtimes, libs all intact)
COPY --from=brew /home/linuxbrew/.linuxbrew /home/linuxbrew/.linuxbrew

ENV SHELL=/bin/zsh \
    ZIM_HOME=/home/developer/.config/zim \
    PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH

# ── All dotfile configs (one layer via bind mounts) ─────
# Runs as root to avoid host file permission issues on bind mounts,
# then chown everything to dev at the end.
RUN --mount=type=bind,source=zsh,target=/tmp/src/zsh \
    --mount=type=bind,source=tmux,target=/tmp/src/tmux \
    --mount=type=bind,source=git,target=/tmp/src/git \
    --mount=type=bind,source=lazygit,target=/tmp/src/lazygit \
    --mount=type=bind,source=k9s,target=/tmp/src/k9s \
    mkdir -p /home/developer/.dotfiles/zsh/conf.d /home/developer/.dotfiles/zsh/themes \
    /home/developer/.dotfiles/zsh/functions /home/developer/.dotfiles/git \
    /home/developer/.config/zim /home/developer/.config/zim-modules \
    /home/developer/.config/fzf /home/developer/.config/bat \
    /home/developer/.config/btop /home/developer/.config/atuin \
    /home/developer/.config/yazi /home/developer/.config/tmux \
    /home/developer/.config/lazygit /home/developer/.config/k9s \
    /home/developer/.config/git \
    && cp /tmp/src/zsh/.zshrc /home/developer/.zshrc \
    && cp /tmp/src/zsh/.config/zim/.zimrc /home/developer/.config/zim/.zimrc \
    && cp -r /tmp/src/zsh/conf.d/. /home/developer/.dotfiles/zsh/conf.d/ \
    && cp -r /tmp/src/zsh/themes/. /home/developer/.dotfiles/zsh/themes/ \
    && cp -r /tmp/src/zsh/functions/. /home/developer/.dotfiles/zsh/functions/ \
    && cp -r /tmp/src/zsh/.config/zim-modules/. /home/developer/.config/zim-modules/ \
    && cp /tmp/src/zsh/.config/starship.toml /home/developer/.config/starship.toml \
    && cp -r /tmp/src/zsh/.config/fzf/. /home/developer/.config/fzf/ \
    && cp -r /tmp/src/zsh/.config/bat/. /home/developer/.config/bat/ \
    && cp -r /tmp/src/zsh/.config/btop/. /home/developer/.config/btop/ \
    && cp -r /tmp/src/zsh/.config/atuin/. /home/developer/.config/atuin/ \
    && cp -r /tmp/src/zsh/.config/yazi/. /home/developer/.config/yazi/ \
    && cp /tmp/src/tmux/.config/tmux/tmux.conf /home/developer/.config/tmux/tmux.conf \
    && cp /tmp/src/tmux/.config/tmux/catppuccin.conf /home/developer/.config/tmux/catppuccin.conf \
    && cp /tmp/src/git/.gitconfig /home/developer/.gitconfig \
    && cp /tmp/src/git/catppuccin.gitconfig /home/developer/.dotfiles/git/catppuccin.gitconfig \
    && cp /tmp/src/git/.config/git/ignore /home/developer/.config/git/ignore \
    && cp -r /tmp/src/lazygit/.config/lazygit/. /home/developer/.config/lazygit/ \
    && cp -r /tmp/src/k9s/.config/k9s/. /home/developer/.config/k9s/ \
    && chown -R developer:developer /home/developer/.dotfiles /home/developer/.config /home/developer/.zshrc /home/developer/.gitconfig

USER developer

# ── Zimfw + TPM + bat cache (one layer) ─────────────────
# 1. zimfw install clones all modules (including zim-starship)
# 2. zim-starship only generates starship-init.zsh when init.zsh is *sourced*,
#    not during zimfw install — so we explicitly generate it via starship CLI
# 3. Verify the generated file contains the correct binary path
RUN command -v starship >/dev/null && echo "starship found at: $(command -v starship)" \
    || { echo "ERROR: starship not in PATH"; exit 1; } \
    && curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
    https://github.com/zimfw/zimfw/releases/download/v1.17.1/zimfw.zsh \
    && ZDOTDIR=${ZIM_HOME} zsh -c 'source ${ZIM_HOME}/zimfw.zsh init -q && source ${ZIM_HOME}/zimfw.zsh install' 2>&1 \
    && starship init zsh --print-full-init > ${ZIM_HOME}/modules/zim-starship/starship-init.zsh \
    && echo "starship-init.zsh generated successfully" \
    && grep -q "$(command -v starship)" "${ZIM_HOME}/modules/zim-starship/starship-init.zsh" \
    && echo "starship path verified in init file" \
    || { echo "ERROR: starship-init.zsh generation or path verification failed"; exit 1; } \
    && git clone --depth 1 --branch v3.1.0 https://github.com/tmux-plugins/tpm \
    /home/developer/.config/tmux/plugins/tpm \
    && { /home/developer/.config/tmux/plugins/tpm/bin/install_plugins 2>&1 || true; } \
    && { bat cache --build 2>/dev/null || true; }

WORKDIR /home/developer

ENTRYPOINT ["/bin/zsh"]
CMD ["-l"]
