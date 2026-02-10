# Tmux Package — Agent Instructions

Rules for working on the tmux configuration.

## Config Structure

```
tmux/
├── .config/tmux/
│   ├── tmux.conf          # Main config (plugins, keybindings, colors)
│   ├── catppuccin.conf    # Catppuccin theme overrides (sourced from tmux.conf)
│   └── plugins/           # Managed by TPM — NOT tracked in git
│       ├── tpm/           # Tmux Plugin Manager
│       ├── tmux-sensible/ # Sensible defaults
│       └── tmux/          # Catppuccin/tmux theme plugin
└── .stow-local-ignore
```

## Plugin Management

Plugins are managed by **TPM** (Tmux Plugin Manager), not by git.

- Plugins are declared via `set -g @plugin '...'` in `tmux.conf`
- Install: `prefix + I` (capital I) inside tmux
- Update: `prefix + U`
- The `plugins/` directory is in `.gitignore` — never commit plugin files
- The `run '~/.config/tmux/plugins/tpm/tpm'` line **must** be the last line

## Theme

Catppuccin Mocha. Two config locations:

1. `tmux.conf` — `@catppuccin_flavor` and status bar layout
2. `catppuccin.conf` — sourced after plugin declarations for theme overrides

When changing the flavor, update `@catppuccin_flavor` in `tmux.conf`.

## Shell

Default shell is hardcoded to Homebrew zsh:

```
set-option -g default-command /opt/homebrew/bin/zsh
```

Do not change to `/bin/zsh` — Homebrew zsh has the correct fpath for completions.

## Keybindings

- `prefix + r` — reload config
- Vi mode enabled for both copy mode (`mode-keys vi`) and command prompt (`status-keys vi`)
