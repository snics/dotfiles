# syntax=docker/dockerfile:1
# ---------------------------------------------------------
# snics/nvim — NeoVim + lazy.nvim plugins + Treesitter + Mason LSPs
#
# Multi-stage build:
#   Stage 1 (builder): compile Treesitter parsers, install Mason tools + LSPs
#   Stage 2 (runtime): slim image with only pre-built artifacts
#
# Build:  docker build -f images/nvim/Dockerfile -t snics/nvim .
# Run:    docker run -it --rm -v $(pwd):/workspace snics/nvim
# ---------------------------------------------------------
ARG DEBIAN_VERSION=bookworm
ARG NVIM_VERSION=0.11.6
ARG GO_VERSION=1.22.5

# ============================================================
# Stage 1: Builder — install plugins, compile parsers, install LSPs
# ============================================================
FROM debian:${DEBIAN_VERSION}-slim AS builder

ARG TARGETARCH
ARG NVIM_VERSION
ARG GO_VERSION

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/dev \
    XDG_CONFIG_HOME=/home/dev/.config \
    XDG_DATA_HOME=/home/dev/.local/share \
    XDG_CACHE_HOME=/home/dev/.cache \
    TERM=xterm-256color

# Exclude docs/man/locale from all packages (saves ~30MB)
RUN echo 'path-exclude=/usr/share/doc/*' >> /etc/dpkg/dpkg.cfg.d/excludes \
    && echo 'path-exclude=/usr/share/man/*' >> /etc/dpkg/dpkg.cfg.d/excludes \
    && echo 'path-exclude=/usr/share/locale/*' >> /etc/dpkg/dpkg.cfg.d/excludes \
    && echo 'path-exclude=/usr/share/info/*' >> /etc/dpkg/dpkg.cfg.d/excludes

# System dependencies for building
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    unzip \
    gcc \
    g++ \
    make \
    nodejs \
    npm \
    python3 \
    python3-pip \
    python3-venv \
    ripgrep

# Create non-root user
RUN groupadd -g 1000 dev \
    && useradd -m -u 1000 -g dev -s /bin/bash dev

# Install Go (needed for gopls and Go-based Mason tools)
RUN GOARCH="${TARGETARCH}" \
    && curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz" \
    | tar -C /usr/local -xzf -

ENV PATH="/usr/local/go/bin:${HOME}/go/bin:${PATH}"

# Install NeoVim from GitHub release (multi-arch) + strip debug symbols
RUN ARCH=$([ "${TARGETARCH}" = "arm64" ] && echo "arm64" || echo "x86_64") \
    && curl -fsSL "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-${ARCH}.tar.gz" \
    | tar -C /usr/local --strip-components=1 -xzf - \
    && strip --strip-unneeded /usr/local/bin/nvim 2>/dev/null || true

USER dev
WORKDIR ${HOME}

# Copy NeoVim config (lazy-lock.json ensures reproducible builds)
COPY --chown=dev:dev nvim/.config/nvim ${XDG_CONFIG_HOME}/nvim

# Step 1: Install lazy.nvim plugins (pinned by lazy-lock.json)
RUN for i in 1 2 3; do \
    nvim --headless "+Lazy! restore" +qa 2>&1 && break \
    || { echo "Lazy restore attempt $i failed, retrying..."; sleep 5; }; \
    done

# Step 2: Compile Treesitter parsers (55+ languages)
# Plugin is lazy-loaded, so we must load it explicitly first
RUN nvim --headless \
    -c "lua require('lazy').load({ plugins = { 'nvim-treesitter' } })" \
    -c "TSUpdate" \
    -c "lua vim.defer_fn(function() vim.cmd('qa') end, 60000)" 2>&1 \
    || true

# Step 3: Install Mason tools (linters, formatters) — best-effort
RUN nvim --headless \
    -c "lua require('lazy').load({ plugins = { 'mason.nvim', 'mason-lspconfig.nvim', 'mason-tool-installer.nvim' } })" \
    -c "MasonToolsInstallSync" \
    -c "lua vim.defer_fn(function() vim.cmd('qa') end, 120000)" 2>&1 \
    || echo "Warning: Some Mason tools may have failed to install"

# Step 4: Install Mason LSP servers explicitly via programmatic API
RUN nvim --headless -c "lua \
    require('lazy').load({ plugins = { 'mason.nvim', 'mason-lspconfig.nvim' } }); \
    local reg = require('mason-registry'); \
    reg.refresh(function() \
    local servers = { \
    'ansible-language-server', 'bash-language-server', 'css-lsp', \
    'docker-compose-language-service', 'dockerfile-language-server', \
    'emmet-ls', 'gopls', 'graphql-language-service-cli', 'helm-ls', \
    'html-lsp', 'json-lsp', 'lua-language-server', 'marksman', \
    'tailwindcss-language-server', 'terraform-ls', \
    'typescript-language-server', 'yaml-language-server', \
    }; \
    local pending = #servers; \
    for _, name in ipairs(servers) do \
    local ok, pkg = pcall(reg.get_package, name); \
    if ok and not pkg:is_installed() then \
    pkg:install():once('closed', function() \
    pending = pending - 1; \
    if pending == 0 then vim.schedule(function() vim.cmd('qa') end) end \
    end); \
    else \
    pending = pending - 1; \
    if pending == 0 then vim.schedule(function() vim.cmd('qa') end) end \
    end \
    end \
    end); \
    vim.defer_fn(function() vim.cmd('qa') end, 300000)" 2>&1 \
    || echo "Warning: Some Mason LSP servers may have failed to install"

# Step 5: Clean up build artifacts to reduce image size
RUN chmod -R u+w ${HOME}/go/pkg 2>/dev/null; \
    rm -rf ${HOME}/go/pkg ${HOME}/go/src \
    && rm -rf ${XDG_CACHE_HOME} \
    && rm -rf ${HOME}/.npm ${HOME}/.cache \
    && rm -rf ${XDG_DATA_HOME}/nvim/mason/staging \
    && find ${XDG_DATA_HOME}/nvim/mason -name "*.log" -delete 2>/dev/null; \
    mkdir -p ${XDG_CACHE_HOME}; \
    true

# ============================================================
# Stage 2: Runtime — slim final image
# ============================================================
FROM debian:${DEBIAN_VERSION}-slim AS runtime

ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/dev \
    XDG_CONFIG_HOME=/home/dev/.config \
    XDG_DATA_HOME=/home/dev/.local/share \
    XDG_CACHE_HOME=/home/dev/.cache \
    TERM=xterm-256color \
    EDITOR=nvim

# Exclude docs/man/locale from all packages
RUN echo 'path-exclude=/usr/share/doc/*' >> /etc/dpkg/dpkg.cfg.d/excludes \
    && echo 'path-exclude=/usr/share/man/*' >> /etc/dpkg/dpkg.cfg.d/excludes \
    && echo 'path-exclude=/usr/share/locale/*' >> /etc/dpkg/dpkg.cfg.d/excludes \
    && echo 'path-exclude=/usr/share/info/*' >> /etc/dpkg/dpkg.cfg.d/excludes

# Runtime-only dependencies (no compiler toolchain)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    nodejs \
    npm \
    python3 \
    python3-venv \
    ripgrep \
    fd-find \
    xclip

# Create non-root user (same UID/GID as builder)
RUN groupadd -g 1000 dev \
    && useradd -m -u 1000 -g dev -s /bin/bash dev

# Copy NeoVim
COPY --from=builder /usr/local/bin/nvim /usr/local/bin/nvim
COPY --from=builder /usr/local/lib/nvim /usr/local/lib/nvim
COPY --from=builder /usr/local/share/nvim /usr/local/share/nvim

# Copy pre-built NeoVim data (plugins, Treesitter parsers, Mason tools)
COPY --from=builder --chown=dev:dev ${XDG_CONFIG_HOME}/nvim ${XDG_CONFIG_HOME}/nvim
COPY --from=builder --chown=dev:dev ${XDG_DATA_HOME}/nvim ${XDG_DATA_HOME}/nvim

# Copy Mason binaries and local tools
COPY --from=builder --chown=dev:dev ${HOME}/.local ${HOME}/.local

# Copy Go tool binaries if present (gopls, golangci-lint compiled by Mason)
COPY --from=builder --chown=dev:dev ${HOME}/go ${HOME}/go

ENV PATH="${HOME}/go/bin:${HOME}/.local/share/nvim/mason/bin:${HOME}/.local/bin:${PATH}"

USER dev
WORKDIR /workspace

ENTRYPOINT ["nvim"]
