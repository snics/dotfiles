# Docker Images

Layered Docker images for a portable development environment accessible via
terminal or browser.

## Image Hierarchy

```
debian:bookworm-slim
  └── snic/nvim                          NeoVim + Treesitter + Mason LSPs
       └── snic/devenv                   CLI/TUI tools (zsh, tmux, brew, starship, lazygit...)
            ├── snic/devenv-web-terminal  + ttyd (browser terminal, Catppuccin Macchiato)
            └── snic/devenv-web-desktop   + XFCE4 desktop via Selkies WebSocket streaming
```

All images share a single user (`developer`) and PATH. No tool duplication.

## Images

### snic/nvim

Minimal NeoVim container with lazy.nvim plugins, Treesitter parsers, and Mason
LSPs pre-installed. Multi-stage build: parsers and LSPs are compiled in a builder
stage, only artifacts are copied to the runtime image.

```bash
docker run -it --rm -v "$(pwd):/home/developer" snic/nvim
```

### snic/devenv

Full CLI/TUI development environment. Adds Homebrew-based tools on top of nvim:
zsh, tmux, starship, lazygit, delta, ripgrep, fd, bat, fzf, and more.

```bash
# Interactive shell with workspace mounted
docker run -it --rm -v "$(pwd):/home/developer/workspace" snic/devenv

# Use as NeoVim with full toolchain
docker run -it --rm -v "$(pwd):/home/developer/workspace" snic/devenv -c 'cd workspace && nvim'
```

### snic/devenv-web-terminal

Browser-accessible terminal via [ttyd](https://github.com/tsl0922/ttyd) with
Catppuccin Macchiato theme. Supports three modes via `TTYD_MODE` env var.

```bash
# Default: zsh shell
docker run --rm -p 7681:7681 snic/devenv-web-terminal
# Open: http://localhost:7681

# tmux session
docker run --rm -p 7681:7681 -e TTYD_MODE=tmux snic/devenv-web-terminal

# NeoVim directly
docker run --rm -p 7681:7681 -e TTYD_MODE=nvim snic/devenv-web-terminal
```

### snic/devenv-web-desktop

Full Linux desktop in the browser via [Selkies](https://github.com/selkies-project/selkies)
WebSocket streaming. XFCE4 desktop with Catppuccin Macchiato GTK theme,
Colloid-Dark window decorations, Plank dock, and Lilex Nerd Font.

```bash
docker run --rm -p 3000:3000 --shm-size=256m snic/devenv-web-desktop
# Open: http://localhost:3000
```

**Note:** `--shm-size=256m` is required for X11 shared memory (MIT-SHM).

#### Desktop Stack

| Component | Purpose |
|-----------|---------|
| Xvfb | Virtual framebuffer (X11 display) |
| XFCE4 | Desktop environment (session, panel, window manager) |
| PulseAudio | Audio streaming |
| Selkies + pixelflux/pcmflux | WebSocket video/audio streaming to browser |
| nginx | HTTP frontend (port 3000), WebSocket proxy |
| Plank | macOS-style dock with Catppuccin Macchiato theme |

#### Theming

| Element | Theme |
|---------|-------|
| GTK | Catppuccin Macchiato Mauve |
| Window decorations (xfwm4) | Colloid-Dark |
| Icons | Papirus-Dark |
| Terminal font | Lilex Nerd Font Mono |
| Plank dock | Catppuccin Macchiato |

## Shell Aliases

Add these to your `~/.zshrc` or `~/.bashrc` for quick access:

```bash
# Interactive devenv shell
alias devsh='docker run -it --rm -v "$(pwd):/home/developer/workspace" snic/devenv'

# NeoVim in browser (port 7681)
alias webvim='docker run --rm -p 7681:7681 -v "$(pwd):/home/developer/workspace" -e TTYD_MODE=nvim snic/devenv-web-terminal'

# tmux in browser (port 7681)
alias webtmux='docker run --rm -p 7681:7681 -v "$(pwd):/home/developer/workspace" -e TTYD_MODE=tmux snic/devenv-web-terminal'

# Full desktop in browser (port 3000)
alias webdesk='docker run --rm -p 3000:3000 --shm-size=256m snic/devenv-web-desktop'

# NeoVim with full devenv toolchain
alias dnvim='docker run -it --rm -v "$(pwd):/home/developer/workspace" snic/devenv -c "cd workspace && nvim"'

# lazygit with full devenv toolchain
alias dlg='docker run -it --rm -v "$(pwd):/home/developer/workspace" snic/devenv -c "cd workspace && lazygit"'
```

## Build & Test

```bash
# Build all images (order matters: nvim -> devenv -> web-*)
just docker-build

# Build individual images
just docker-build-nvim
just docker-build-devenv
just docker-build-web-terminal
just docker-build-web-desktop

# Run smoke tests
just docker-test

# Lint Dockerfiles
just docker-lint

# Push to Docker Hub (multi-arch: amd64 + arm64)
just docker-push
```

## Wallpaper

The desktop wallpaper (`fuji-winter.jpg`) is sourced from
[Wallhaven](https://wallhaven.cc/w/8xv35o) and used under
[Wallhaven's terms](https://wallhaven.cc/about#terms). The image is a
photograph of Mount Fuji in winter (3000x2002, 771 KB).

## License

The Docker images and configuration files in this directory are part of the
[dotfiles](https://github.com/snics/dotfiles) repository. Third-party
components have their own licenses:

| Component | License |
|-----------|---------|
| [Catppuccin GTK](https://github.com/catppuccin/gtk) | MIT |
| [Catppuccin Plank](https://github.com/catppuccin/plank) | MIT |
| [Catppuccin xfce4-terminal](https://github.com/catppuccin/xfce4-terminal) | MIT |
| [Colloid GTK Theme](https://github.com/vinceliuice/Colloid-gtk-theme) | GPL-3.0 |
| [Papirus Icon Theme](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) | GPL-3.0 |
| [Lilex Nerd Font](https://github.com/ryanoasis/nerd-fonts) | MIT (Lilex) + MIT (Nerd Fonts patcher) |
| [Selkies](https://github.com/selkies-project/selkies) | MPL-2.0 |
| [pixelflux](https://github.com/linuxserver/pixelflux) / [pcmflux](https://github.com/linuxserver/pcmflux) | GPL-3.0 |
| [ttyd](https://github.com/tsl0922/ttyd) | MIT |
