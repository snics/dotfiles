# syntax=docker/dockerfile:1
# ---------------------------------------------------------
# snics/devenv — Full CLI + TUI development environment
#
# Multi-stage build:
#   Stage 1 (brew): install CLI tools via Homebrew bottles
#   Stage 2 (final): FROM snics/nvim + shell + TUI tools + configs
#
# Build:  docker build -f _images/devenv/Dockerfile -t snics/devenv .
# Run:    docker run -it --rm -v $(pwd):/workspace snics/devenv
# ---------------------------------------------------------
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
    brew install "$pkg" 2>&1 || { echo "WARN: failed to install $pkg"; failed="$failed $pkg"; }; \
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

LABEL org.opencontainers.image.source="https://github.com/snics/dotfiles" \
    org.opencontainers.image.title="snics/devenv" \
    org.opencontainers.image.description="Full CLI + TUI development environment"

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
    zsh tmux jq less file locales \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && chsh -s /bin/zsh dev

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Copy entire Homebrew prefix from brew stage (scripts, runtimes, libs all intact)
COPY --from=brew /home/linuxbrew/.linuxbrew /home/linuxbrew/.linuxbrew

ENV SHELL=/bin/zsh \
    ZIM_HOME=/home/dev/.config/zim \
    PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH

# ── All dotfile configs (one layer via bind mounts) ─────
# Runs as root to avoid host file permission issues on bind mounts,
# then chown everything to dev at the end.
RUN --mount=type=bind,source=zsh,target=/tmp/src/zsh \
    --mount=type=bind,source=tmux,target=/tmp/src/tmux \
    --mount=type=bind,source=git,target=/tmp/src/git \
    --mount=type=bind,source=lazygit,target=/tmp/src/lazygit \
    --mount=type=bind,source=k9s,target=/tmp/src/k9s \
    mkdir -p /home/dev/.dotfiles/zsh/conf.d /home/dev/.dotfiles/zsh/themes \
    /home/dev/.dotfiles/zsh/functions /home/dev/.dotfiles/git \
    /home/dev/.config/zim /home/dev/.config/zim-modules \
    /home/dev/.config/fzf /home/dev/.config/bat \
    /home/dev/.config/btop /home/dev/.config/atuin \
    /home/dev/.config/yazi /home/dev/.config/tmux \
    /home/dev/.config/lazygit /home/dev/.config/k9s \
    /home/dev/.config/git \
    && cp /tmp/src/zsh/.zshrc /home/dev/.zshrc \
    && cp /tmp/src/zsh/.config/zim/.zimrc /home/dev/.config/zim/.zimrc \
    && cp -r /tmp/src/zsh/conf.d/. /home/dev/.dotfiles/zsh/conf.d/ \
    && cp -r /tmp/src/zsh/themes/. /home/dev/.dotfiles/zsh/themes/ \
    && cp -r /tmp/src/zsh/functions/. /home/dev/.dotfiles/zsh/functions/ \
    && cp -r /tmp/src/zsh/.config/zim-modules/. /home/dev/.config/zim-modules/ \
    && cp /tmp/src/zsh/.config/starship.toml /home/dev/.config/starship.toml \
    && cp -r /tmp/src/zsh/.config/fzf/. /home/dev/.config/fzf/ \
    && cp -r /tmp/src/zsh/.config/bat/. /home/dev/.config/bat/ \
    && cp -r /tmp/src/zsh/.config/btop/. /home/dev/.config/btop/ \
    && cp -r /tmp/src/zsh/.config/atuin/. /home/dev/.config/atuin/ \
    && cp -r /tmp/src/zsh/.config/yazi/. /home/dev/.config/yazi/ \
    && cp /tmp/src/tmux/.config/tmux/tmux.conf /home/dev/.config/tmux/tmux.conf \
    && cp /tmp/src/tmux/.config/tmux/catppuccin.conf /home/dev/.config/tmux/catppuccin.conf \
    && cp /tmp/src/git/.gitconfig /home/dev/.gitconfig \
    && cp /tmp/src/git/catppuccin.gitconfig /home/dev/.dotfiles/git/catppuccin.gitconfig \
    && cp /tmp/src/git/.config/git/ignore /home/dev/.config/git/ignore \
    && cp -r /tmp/src/lazygit/.config/lazygit/. /home/dev/.config/lazygit/ \
    && cp -r /tmp/src/k9s/.config/k9s/. /home/dev/.config/k9s/ \
    && chown -R dev:dev /home/dev/.dotfiles /home/dev/.config /home/dev/.zshrc /home/dev/.gitconfig

USER dev

# ── Zimfw + TPM + bat cache (one layer) ─────────────────
# 1. zimfw install clones all modules (including zim-starship)
# 2. zim-starship only generates starship-init.zsh when init.zsh is *sourced*,
#    not during zimfw install — so we explicitly generate it via starship CLI
# 3. Verify the generated file contains the correct binary path
RUN command -v starship >/dev/null && echo "starship found at: $(command -v starship)" \
    || { echo "ERROR: starship not in PATH"; exit 1; } \
    && curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
    https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh \
    && ZDOTDIR=${ZIM_HOME} zsh -c 'source ${ZIM_HOME}/zimfw.zsh init -q && source ${ZIM_HOME}/zimfw.zsh install' 2>&1 \
    && starship init zsh --print-full-init > ${ZIM_HOME}/modules/zim-starship/starship-init.zsh \
    && echo "starship-init.zsh generated successfully" \
    && grep -q "$(command -v starship)" "${ZIM_HOME}/modules/zim-starship/starship-init.zsh" \
    && echo "starship path verified in init file" \
    || { echo "ERROR: starship-init.zsh generation or path verification failed"; exit 1; } \
    && git clone --depth 1 https://github.com/tmux-plugins/tpm \
    /home/dev/.config/tmux/plugins/tpm \
    && { /home/dev/.config/tmux/plugins/tpm/bin/install_plugins 2>&1 || true; } \
    && { bat cache --build 2>/dev/null || true; }

WORKDIR /workspace

ENTRYPOINT ["/bin/zsh"]
CMD ["-l"]
