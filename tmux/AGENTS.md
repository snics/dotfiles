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

Prefix: **Ctrl+Space** (changed from default Ctrl+b).

### Navigation (no prefix needed)

- `Ctrl+h/j/k/l` — navigate panes (via vim-tmux-navigator, seamless with NeoVim)

### Splits & Resize

- `prefix + |` or `prefix + \` — vertical split (current dir)
- `prefix + -` — horizontal split (current dir)
- `prefix + H/J/K/L` — resize pane (repeatable, 5px)
- `prefix + z` — zoom toggle
- `prefix + c` — new window (current dir)

### Vi Copy Mode

- `prefix + v` — enter copy mode
- `v` / `V` / `Ctrl+v` — selection / line / rectangle
- `y` — copy to clipboard (pbcopy)

### TUI Popups (90% overlay, auto-close)

- `prefix + f` — yazi (**f**iles)
- `prefix + g` — lazygit (**g**it)
- `prefix + s` — btop (**s**ystem monitor)
- `prefix + k` — k9s (**k**ubernetes)

Keys match the shell Alt+key bindings (`Alt+F/G/S/K` in `zsh/conf.d/50-keybindings.zsh`).

### Management

- `prefix + r` — reload config
- `prefix + I` — install plugins (TPM)
- `prefix + U` — update plugins

Vi mode enabled for both copy mode (`mode-keys vi`) and command prompt (`status-keys vi`).

When changing keybindings, also update `_docs/keybindings.md`.
