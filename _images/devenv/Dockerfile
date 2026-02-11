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
# Stage 1: Install CLI tools via Homebrew (pre-compiled bottles)
# ============================================================
FROM homebrew/brew:latest AS brew

ENV HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    HOMEBREW_NO_ANALYTICS=1 \
    HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1 \
    HOMEBREW_NO_ENV_HINTS=1

RUN brew install \
    lazygit \
    k9s \
    lazydocker \
    starship \
    zoxide \
    git-delta \
    fzf \
    atuin \
    eza \
    bat \
    btop \
    yazi \
    patchelf

# Stage binaries + shared libs for multi-stage COPY
# Static binaries (Go): just copy
# Dynamic binaries (Rust/C++): patchelf to use system ld + bundled libs
RUN INTERP=$(ls /lib/ld-linux-*.so.* 2>/dev/null | head -1) \
    && mkdir -p /tmp/staging/bin /tmp/staging/lib \
    && for bin in lazygit k9s lazydocker fzf; do \
    cp "$(readlink -f /home/linuxbrew/.linuxbrew/bin/$bin)" /tmp/staging/bin/$bin; \
    done \
    && for bin in bat starship zoxide delta atuin eza btop yazi; do \
    real="$(readlink -f /home/linuxbrew/.linuxbrew/bin/$bin)"; \
    cp "$real" /tmp/staging/bin/$bin; \
    chmod +w /tmp/staging/bin/$bin; \
    ldd "$real" 2>/dev/null | grep linuxbrew | grep -v ld-linux | awk '{print $1, $3}' | \
    while read soname libpath; do \
    actual="$(readlink -f "$libpath")"; \
    cp -n "$actual" /tmp/staging/lib/ 2>/dev/null || true; \
    ln -sf "$(basename "$actual")" /tmp/staging/lib/"$soname" 2>/dev/null || true; \
    done; \
    patchelf --set-interpreter "$INTERP" --set-rpath /usr/local/lib /tmp/staging/bin/$bin; \
    done

# ============================================================
# Stage 2: Final image — snics/nvim + shell + TUI tools
# ============================================================
FROM snics/nvim:${NVIM_TAG}

USER root

# Exclude docs/man/locale from all packages
RUN echo 'path-exclude=/usr/share/doc/*' >> /etc/dpkg/dpkg.cfg.d/excludes \
    && echo 'path-exclude=/usr/share/man/*' >> /etc/dpkg/dpkg.cfg.d/excludes \
    && echo 'path-exclude=/usr/share/locale/*' >> /etc/dpkg/dpkg.cfg.d/excludes \
    && echo 'path-exclude=/usr/share/info/*' >> /etc/dpkg/dpkg.cfg.d/excludes

# Shell, TUI, and runtime dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    zsh \
    tmux \
    jq \
    less \
    file \
    locales \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Copy CLI tool binaries and shared libs from Homebrew stage
COPY --from=brew /tmp/staging/bin/ /usr/local/bin/
COPY --from=brew /tmp/staging/lib/ /usr/local/lib/

# Set zsh as default shell for dev user
RUN chsh -s /bin/zsh dev

USER dev

ENV SHELL=/bin/zsh

# ── Zsh + Zimfw ─────────────────────────────────────────

# Use original configs directly (cross-platform guards handle macOS vs Docker)
COPY --chown=dev:dev zsh/.zshrc                        ${HOME}/.zshrc
COPY --chown=dev:dev zsh/.config/zim/.zimrc            ${XDG_CONFIG_HOME}/zim/.zimrc

# Copy portable zsh configs (conf.d files sourced by .zshrc loop)
COPY --chown=dev:dev zsh/conf.d/00-init.zsh            ${HOME}/.dotfiles/zsh/conf.d/00-init.zsh
COPY --chown=dev:dev zsh/conf.d/10-path.zsh            ${HOME}/.dotfiles/zsh/conf.d/10-path.zsh
COPY --chown=dev:dev zsh/conf.d/20-aliases.zsh         ${HOME}/.dotfiles/zsh/conf.d/20-aliases.zsh
COPY --chown=dev:dev zsh/conf.d/30-fzf-tab.zsh         ${HOME}/.dotfiles/zsh/conf.d/30-fzf-tab.zsh
COPY --chown=dev:dev zsh/conf.d/40-fzf.zsh             ${HOME}/.dotfiles/zsh/conf.d/40-fzf.zsh
COPY --chown=dev:dev zsh/conf.d/50-keybindings.zsh     ${HOME}/.dotfiles/zsh/conf.d/50-keybindings.zsh
COPY --chown=dev:dev zsh/conf.d/60-atuin.zsh           ${HOME}/.dotfiles/zsh/conf.d/60-atuin.zsh
COPY --chown=dev:dev zsh/conf.d/70-functions.zsh       ${HOME}/.dotfiles/zsh/conf.d/70-functions.zsh
COPY --chown=dev:dev zsh/conf.d/80-gnu-generic.zsh     ${HOME}/.dotfiles/zsh/conf.d/80-gnu-generic.zsh
COPY --chown=dev:dev zsh/conf.d/90-completions.zsh     ${HOME}/.dotfiles/zsh/conf.d/90-completions.zsh

# Copy zsh themes and functions
COPY --chown=dev:dev zsh/themes/   ${HOME}/.dotfiles/zsh/themes/
COPY --chown=dev:dev zsh/functions/ ${HOME}/.dotfiles/zsh/functions/

# Copy custom zim modules (bat, eza — fully portable)
COPY --chown=dev:dev zsh/.config/zim-modules/ ${XDG_CONFIG_HOME}/zim-modules/

# Initialize Zimfw (download zimfw.zsh + install plugins)
ENV ZIM_HOME=${XDG_CONFIG_HOME}/zim

RUN curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
    https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh \
    && zsh -c 'source ${ZIM_HOME}/zimfw.zsh init -q && source ${ZIM_HOME}/zimfw.zsh install' 2>&1 || true

# ── Starship prompt ─────────────────────────────────────
COPY --chown=dev:dev zsh/.config/starship.toml ${XDG_CONFIG_HOME}/starship.toml

# ── fzf config (Catppuccin theme) ───────────────────────
COPY --chown=dev:dev zsh/.config/fzf/config ${XDG_CONFIG_HOME}/fzf/config

# ── tmux + TPM (uses original config with if-shell guards) ──
COPY --chown=dev:dev tmux/.config/tmux/tmux.conf       ${XDG_CONFIG_HOME}/tmux/tmux.conf
COPY --chown=dev:dev tmux/.config/tmux/catppuccin.conf ${XDG_CONFIG_HOME}/tmux/catppuccin.conf

# Install TPM and plugins
RUN git clone --depth 1 https://github.com/tmux-plugins/tpm \
    ${XDG_CONFIG_HOME}/tmux/plugins/tpm \
    && ${XDG_CONFIG_HOME}/tmux/plugins/tpm/bin/install_plugins 2>&1 || true

# ── Git config ──────────────────────────────────────────
COPY --chown=dev:dev git/.gitconfig          ${HOME}/.gitconfig
COPY --chown=dev:dev git/catppuccin.gitconfig ${HOME}/.dotfiles/git/catppuccin.gitconfig
COPY --chown=dev:dev git/.config/git/ignore  ${XDG_CONFIG_HOME}/git/ignore

# ── TUI tool configs (Catppuccin everywhere) ────────────
COPY --chown=dev:dev lazygit/.config/lazygit/ ${XDG_CONFIG_HOME}/lazygit/
COPY --chown=dev:dev k9s/.config/k9s/         ${XDG_CONFIG_HOME}/k9s/
COPY --chown=dev:dev zsh/.config/bat/          ${XDG_CONFIG_HOME}/bat/
COPY --chown=dev:dev zsh/.config/btop/         ${XDG_CONFIG_HOME}/btop/
COPY --chown=dev:dev zsh/.config/atuin/        ${XDG_CONFIG_HOME}/atuin/
COPY --chown=dev:dev zsh/.config/yazi/         ${XDG_CONFIG_HOME}/yazi/

# Build bat theme cache
RUN bat cache --build 2>/dev/null || true

WORKDIR /workspace

ENTRYPOINT ["/bin/zsh"]
CMD ["-l"]
