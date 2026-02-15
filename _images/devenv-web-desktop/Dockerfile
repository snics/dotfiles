# syntax=docker/dockerfile:1
# ---------------------------------------------------------
# snics/devenv-web-desktop — Full Linux desktop in the browser
#
# Stack: Xvfb + XFCE4 + PulseAudio + Selkies (pixelflux/pcmflux WebSocket streaming)
# Inherits all CLI tools from snics/devenv (Homebrew, zsh, nvim, tmux, etc.)
#
# Build:  docker build -t snics/devenv-web-desktop _images/devenv-web-desktop
# Run:    docker run --rm -p 3000:3000 --shm-size=256m snics/devenv-web-desktop
# Open:   http://localhost:3000
#
# Architecture: amd64 + arm64 (pixelflux/pcmflux PyPI wheels for both)
#
# Refs: https://github.com/selkies-project/selkies
#       https://github.com/linuxserver/pixelflux
#       https://github.com/linuxserver/pcmflux
# ---------------------------------------------------------
ARG DEVENV_TAG=latest
ARG SELKIES_COMMIT=a47ade9aad57758f0e3ee421240db53ad8c3d3b2
# SHA256 checksums for binary downloads (supply-chain integrity)
ARG LIBVA_SHA256=e3da2250654c8d52b3f59f8cb3f3d8e7fb1a2ee64378dbc400fbc5663de7edb8
ARG LILEX_FONT_SHA256=cfad2ef0b3867607a988978ea4a74e68bc899f3b9bbd48e32b27b54bb700a82f
ARG CATPPUCCIN_GTK_SHA256=b8186e47a9d09266f54b38c6e58dd2837fe53d9786532ce206c1fc3c7b658573

# ── Stage 1: Build web frontend (arch-independent) ─────
FROM node:22.15.1-slim AS frontend

ARG SELKIES_COMMIT

RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/selkies-project/selkies.git /src \
    && cd /src && git checkout -f ${SELKIES_COMMIT}

WORKDIR /src/addons/gst-web-core
RUN npm install && npm run build

WORKDIR /src/addons/selkies-dashboard
RUN cp ../gst-web-core/dist/selkies-core.js src/ \
    && npm install && npm run build \
    && mkdir -p dist/src dist/nginx \
    && cp ../gst-web-core/dist/selkies-core.js dist/src/ \
    && cp ../universal-touch-gamepad/universalTouchGamepad.js dist/src/ \
    && cp ../gst-web-core/nginx/* dist/nginx/ \
    && cp -r ../gst-web-core/dist/jsdb dist/ \
    && mkdir -p /buildout \
    && cp -ar dist/* /buildout/

# ── Stage 2: Runtime ────────────────────────────────────
FROM snics/devenv:${DEVENV_TAG}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG IMAGE_VERSION=dev

LABEL org.opencontainers.image.source="https://github.com/snics/dotfiles" \
    org.opencontainers.image.title="snics/devenv-web-desktop" \
    org.opencontainers.image.description="Browser-accessible Linux desktop via Selkies WebSocket streaming" \
    org.opencontainers.image.version="${IMAGE_VERSION}"

USER root

ARG SELKIES_COMMIT
ARG LIBVA_VERSION=2.22.0
ARG LIBVA_SHA256
ARG LILEX_FONT_SHA256
ARG CATPPUCCIN_GTK_SHA256

# --- System packages (runtime + build), libva build, Colloid theme, cleanup ---
# Single apt-get layer: install everything, build what's needed, purge build deps.
# hadolint ignore=DL3008
RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /var/cache/apt/*.bin \
    && apt-get clean \
    && apt-get update && apt-get install -y --no-install-recommends \
    # --- X11 / display ---
    xvfb xauth x11-utils x11-xkb-utils x11-xserver-utils \
    libxcb1 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
    libxdamage1 libxfixes3 libxv1 libxtst6 libxext6 libx11-xcb1 \
    libxcb-dri3-0 libxkbcommon0 libxinerama1 libxkbcommon-x11-0 \
    # --- Audio ---
    pulseaudio libpulse0 pulseaudio-utils libopus0 \
    # --- Desktop environment ---
    xfce4 xfce4-terminal thunar \
    gtk2-engines-murrine gnome-themes-extra \
    papirus-icon-theme adwaita-icon-theme \
    librsvg2-common \
    dbus dbus-x11 \
    xdotool xclip \
    plank \
    # --- Web server + supervisor ---
    nginx supervisor \
    # --- Fonts ---
    fonts-noto-core \
    # --- Python (for Selkies) ---
    python3 python3-pip python3-venv python3-dev \
    # --- Build-only deps (purged at end of this layer) ---
    linux-libc-dev gcc sassc git \
    meson ninja-build pkg-config dpkg-dev \
    libdrm-dev libx11-dev libxext-dev libxfixes-dev libxkbcommon-dev \
    libx11-xcb-dev libxcb-dri3-dev libwayland-dev wayland-protocols \
    curl unzip \
    && \
    # --- Build libva 2.22 (Bookworm's 2.17 lacks vaMapBuffer2 for pixelflux) ---
    MULTIARCH=$(dpkg-architecture -qDEB_HOST_MULTIARCH) \
    && rm -f /usr/lib/${MULTIARCH}/libva*.so* \
    && curl -fsSL -o /tmp/libva.tar.bz2 "https://github.com/intel/libva/releases/download/${LIBVA_VERSION}/libva-${LIBVA_VERSION}.tar.bz2" \
    && echo "${LIBVA_SHA256}  /tmp/libva.tar.bz2" | sha256sum -c - \
    && tar xjf /tmp/libva.tar.bz2 -C /tmp \
    && rm /tmp/libva.tar.bz2 \
    && cd /tmp/libva-${LIBVA_VERSION} \
    && meson setup build --prefix=/usr --libdir=/usr/lib/${MULTIARCH} \
    && ninja -C build \
    && ninja -C build install \
    && ldconfig \
    && rm -rf /tmp/libva-* \
    && cd /tmp \
    && \
    # --- Build Colloid GTK/xfwm4 theme ---
    git clone --depth=1 --branch 2025-07-31 https://github.com/vinceliuice/Colloid-gtk-theme.git /tmp/colloid \
    && cd /tmp/colloid \
    && ./install.sh --dest /usr/share/themes --name Colloid \
    --theme default --color dark --size standard --tweaks normal \
    && rm -rf /tmp/colloid \
    && \
    # --- Install Selkies + pixelflux + pcmflux + joystick interposer ---
    # Single download: pip install + compile joystick interposer while gcc is available.
    # Uses system Python — Homebrew's Python 3.14 breaks python-xlib.
    curl -fsSL "https://github.com/selkies-project/selkies/archive/${SELKIES_COMMIT}.tar.gz" \
    | tar xzf - -C /tmp \
    && cd /tmp/selkies-* \
    && sed -i '/"av[>=]/d' pyproject.toml \
    && sed -i '/cryptography/d' pyproject.toml \
    && /usr/bin/python3 -m venv --system-site-packages /opt/selkies \
    && /opt/selkies/bin/pip install --no-cache-dir . setuptools \
    && cd addons/js-interposer \
    && gcc -shared -fPIC -ldl -o /usr/lib/selkies_joystick_interposer.so joystick_interposer.c \
    && rm -rf /tmp/selkies-* \
    && \
    # --- Purge build-only packages ---
    apt-get purge -y --auto-remove \
    linux-libc-dev gcc sassc \
    meson ninja-build pkg-config dpkg-dev \
    libdrm-dev libx11-dev libxext-dev libxfixes-dev libxkbcommon-dev \
    libx11-xcb-dev libxcb-dri3-dev libwayland-dev wayland-protocols \
    python3-dev python3-pip \
    && rm -rf /var/lib/apt/lists/*

# --- Web dashboard from frontend stage ---
COPY --from=frontend /buildout /usr/share/selkies/web

# --- Themes, fonts, and desktop config (single layer) ---
RUN cd /tmp \
    && \
    # Catppuccin GTK theme (Macchiato Mauve)
    curl -fsSL -o catppuccin-gtk.zip \
    "https://github.com/catppuccin/gtk/releases/download/v1.0.3/catppuccin-macchiato-mauve-standard+default.zip" \
    && echo "${CATPPUCCIN_GTK_SHA256}  catppuccin-gtk.zip" | sha256sum -c - \
    && unzip -q catppuccin-gtk.zip -d /usr/share/themes/ \
    && rm catppuccin-gtk.zip \
    && \
    # Catppuccin xfce4-terminal colorscheme (inline — upstream repo was deleted)
    mkdir -p /home/developer/.local/share/xfce4/terminal/colorschemes \
    && printf '[Scheme]\nName=Catppuccin Macchiato\nColorForeground=#cad3f5\nColorBackground=#24273a\nColorCursor=#f4dbd6\nColorSelection=#5b6078\nColorSelectionUse=TRUE\nColorBold=#cad3f5\nColorBoldUse=TRUE\nTabActivityColor=#c6a0f6\nColorPalette=#494d64;#ed8796;#a6da95;#eed49f;#8aadf4;#f5bde6;#8bd5ca;#b8c0e0;#5b6078;#ed8796;#a6da95;#eed49f;#8aadf4;#f5bde6;#8bd5ca;#a5adcb\n' \
    > /home/developer/.local/share/xfce4/terminal/colorschemes/catppuccin-macchiato.theme \
    && \
    # Lilex Nerd Font (same as Ghostty config)
    mkdir -p /usr/share/fonts/truetype/lilex-nerd-font \
    && curl -fsSL -o lilex.zip \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Lilex.zip" \
    && echo "${LILEX_FONT_SHA256}  lilex.zip" | sha256sum -c - \
    && unzip -q lilex.zip -d /usr/share/fonts/truetype/lilex-nerd-font/ \
    && rm lilex.zip \
    && fc-cache -fv > /dev/null 2>&1 \
    && \
    # Catppuccin Plank dock theme (Macchiato)
    mkdir -p /usr/share/plank/themes/Catppuccin-macchiato \
    && printf '[PlankTheme]\nTopRoundness=17\nBottomRoundness=17\nLineWidth=0\nOuterStrokeColor=36;;39;;58;;240\nFillStartColor=36;;39;;58;;240\nFillEndColor=36;;39;;58;;240\nInnerStrokeColor=54;;58;;79;;240\n\n[PlankDockTheme]\nHorizPadding=1.75\nTopPadding=1.75\nBottomPadding=2\nItemPadding=2\nIndicatorSize=5\nIconShadowSize=1.25\nUrgentBounceHeight=1.75\nLaunchBounceHeight=0.625\nFadeOpacity=1\nClickTime=175\nUrgentBounceTime=600\nLaunchBounceTime=600\nActiveTime=25\nSlideTime=450\nFadeTime=350\nHideTime=375\nGlowSize=30\nGlowTime=10000\nGlowPulseTime=2750\nUrgentHueShift=175\nItemMoveTime=450\nCascadeHide=true\nBadgeColor=0;;0;;0;;0\n' \
    > /usr/share/plank/themes/Catppuccin-macchiato/dock.theme \
    && \
    # GTK3 settings
    mkdir -p /home/developer/.config/gtk-3.0 \
    && printf '[Settings]\ngtk-theme-name=catppuccin-macchiato-mauve-standard+default\ngtk-icon-theme-name=Papirus-Dark\ngtk-font-name=Noto Sans 10\ngtk-cursor-theme-name=Adwaita\ngtk-cursor-theme-size=24\ngtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ\ngtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR\ngtk-button-images=1\ngtk-menu-images=1\ngtk-enable-event-sounds=0\ngtk-enable-input-feedback-sounds=0\ngtk-xft-antialias=1\ngtk-xft-hinting=1\ngtk-xft-hintstyle=hintslight\ngtk-application-prefer-dark-theme=1\n' \
    > /home/developer/.config/gtk-3.0/settings.ini \
    && \
    # GTK2 settings
    printf 'gtk-theme-name="catppuccin-macchiato-mauve-standard+default"\ngtk-icon-theme-name="Papirus-Dark"\ngtk-font-name="Noto Sans 10"\ngtk-cursor-theme-name="Adwaita"\ngtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ\ngtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR\ngtk-button-images=1\ngtk-menu-images=1\n' \
    > /home/developer/.gtkrc-2.0 \
    && \
    # Plank dock autostart + launcher config
    mkdir -p /home/developer/.config/autostart \
    /home/developer/.config/plank/dock1/launchers \
    && printf '[Desktop Entry]\nType=Application\nExec=plank\nHidden=false\nNoDisplay=false\nX-GNOME-Autostart-enabled=true\nName=Plank\n' \
    > /home/developer/.config/autostart/plank.desktop \
    && printf '[PlankDockPreferences]\nHideMode=0\nUnhideDelay=0\nItemsAlignment=3\nIconSize=48\nTheme=Catppuccin-macchiato\nPosition=3\nOffset=0\nDockItems=thunar.dockitem;;xfce4-terminal.dockitem;;xfce4-appfinder.dockitem\n' \
    > /home/developer/.config/plank/dock1/settings \
    && printf '[PlankDockItemPreferences]\nLauncher=file:///usr/share/applications/thunar.desktop\n' \
    > /home/developer/.config/plank/dock1/launchers/thunar.dockitem \
    && printf '[PlankDockItemPreferences]\nLauncher=file:///usr/share/applications/xfce4-terminal.desktop\n' \
    > /home/developer/.config/plank/dock1/launchers/xfce4-terminal.dockitem \
    && printf '[PlankDockItemPreferences]\nLauncher=file:///usr/share/applications/xfce4-appfinder.desktop\n' \
    > /home/developer/.config/plank/dock1/launchers/xfce4-appfinder.dockitem

# --- Desktop wallpaper ---
COPY wallpapers/ /home/developer/.local/share/backgrounds/

# --- XFCE4 configuration (headless pre-seed) ---
COPY xfce4-config/xfce-perchannel-xml/ /home/developer/.config/xfce4/xfconf/xfce-perchannel-xml/
COPY xfce4-config/terminalrc /home/developer/.config/xfce4/terminal/terminalrc

# --- Runtime config files ---
COPY nginx.conf /etc/nginx/sites-available/selkies.conf
COPY supervisord.conf /etc/supervisor/conf.d/desktop.conf
COPY start-desktop.sh /usr/local/bin/start-desktop.sh

RUN chmod +x /usr/local/bin/start-desktop.sh \
    && mkdir -p /tmp/.X11-unix /run/dbus \
    && chmod 1777 /tmp/.X11-unix \
    && chown -R developer:developer /home/developer/.config /home/developer/.local \
    && ln -sf /etc/nginx/sites-available/selkies.conf /etc/nginx/sites-enabled/selkies.conf \
    && rm -f /etc/nginx/sites-enabled/default \
    # Allow nginx to run as non-root (developer user):
    # - Redirect pid and error_log to /tmp (writable without root)
    # - Grant ownership of runtime dirs to developer
    && sed -i 's|/run/nginx.pid|/tmp/nginx.pid|' /etc/nginx/nginx.conf \
    && sed -i 's|error_log /var/log/nginx/error.log|error_log /tmp/nginx-error.log|' /etc/nginx/nginx.conf \
    && chown -R developer:developer /var/lib/nginx /var/log/nginx

ENV DISPLAY=:1 \
    RESOLUTION=1920x1080x24 \
    SELKIES_ENCODER=x264enc \
    SELKIES_INTERPOSER=/usr/lib/selkies_joystick_interposer.so \
    PATH="/opt/selkies/bin:$PATH"

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

ENTRYPOINT ["/usr/local/bin/start-desktop.sh"]
