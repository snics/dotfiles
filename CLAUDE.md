# Dotfiles — Claude Code Instructions

Project-specific instructions for Claude Code working on this dotfiles repository.

## Repository Structure

GNU Stow-managed dotfiles. Each top-level directory is a stow package that
symlinks into `$HOME` via `stow <package>` from the repo root.

```
_docs/       → Documentation and screenshots (not a stow package)
_images/     → Docker build files: nvim/, devenv/, devenv-web/ (not a stow package)
_install/    → Setup scripts (not a stow package)
_macOS/      → macOS system settings scripts (not a stow package)
_planning/   → Project planning docs (not a stow package)
asdf/        → asdf version manager plugins
brew/        → Split Brewfiles (Brewfile.00-taps … Brewfile.90-mas, not a stow package)
claude/      → ~/.claude/ (Claude Code user config, MCP servers)
cursor/      → Cursor editor config
ghostty/     → ~/.config/ghostty/ (terminal emulator)
git/         → ~/.config/git/ + ~/.gitconfig
k9s/         → ~/.config/k9s/ (Kubernetes TUI)
lazygit/     → ~/.config/lazygit/
nvim/        → ~/.config/nvim/ (NeoVim)
obsidian/    → Obsidian vault structure
opencode/    → ~/.config/opencode/ (AI coding agent)
tmux/        → ~/.config/tmux/
zed/         → ~/.config/zed/ (Zed editor)
zsh/         → Zsh shell config (conf.d/, functions/, themes/)
```

## General Rules

- **Language**: English for all commits, comments, and documentation
- **Commits**: [Conventional Commits](https://www.conventionalcommits.org/) with gitmoji prefix
  - Format: `<gitmoji> <type>(scope): <description>`
  - Scopes match package directories: `zsh`, `nvim`, `zed`, `brew`, `git`, etc.
- **Stow**: `~/.stow-global-ignore` handles .git, .DS_Store, README, LICENSE,
  AGENTS.md, CLAUDE.md. Package-specific ignores go in `.stow-local-ignore`.

## Package-Specific Instructions

Detailed rules live in each package's `AGENTS.md`:

| File | Scope |
|------|-------|
| `brew/AGENTS.md` | Brewfile changes and cross-package sync obligations |
| `zsh/AGENTS.md` | Zsh config structure, atuin stats maintenance |
| `nvim/AGENTS.md` | NeoVim config, keybindings, cross-sync with Zed |
| `zed/AGENTS.md` | Zed editor config, keybindings, cross-sync with NeoVim |

## Justfile / Makefile Sync Rule

Both `justfile` and `Makefile` expose identical targets. When adding or modifying
a target, **always update both files**. The Justfile is the primary interface;
the Makefile is the universal fallback for environments without `just`.

Run `just --list` or `make help` to verify targets match after changes.

## Brew Package Management

The `brew/` directory is **not a stow package** — it contains split Brewfile
source files that are concatenated into `~/.Brewfile` at shell startup.

### How it works

1. `zsh/conf.d/00-init.zsh` sets `HOMEBREW_BUNDLE_FILE=~/.Brewfile`
2. `zsh/conf.d/15-brew.zsh` regenerates `~/.Brewfile` from `brew/Brewfile.*`
   when any source file is newer (runs on every new shell, fast no-op otherwise)
3. All `brew bundle` commands work without `--file` flags

### Split files (13 categories, numeric prefix = load order)

Taps (`00`) must come first. Add new tools to the matching category file.
See `brew/AGENTS.md` for the full file list and sync obligations.

### Key commands

| Command | Description |
|---------|-------------|
| `brew bundle` | Install all packages (uses `~/.Brewfile` automatically) |
| `brew bundle check` | Show missing packages |
| `brew bundle cleanup` | Show packages not in Brewfile |
| `just brew-install` | Regenerate + install |
| `just brew-dump` | Dump installed packages for comparison |

### Docker images

The Docker devenv image (`_images/devenv/Dockerfile`) mirrors the macOS CLI
environment as closely as possible. It uses a multi-stage build:

1. **Brew stage**: COPYs `brew/Brewfile.*` into a `homebrew/brew` builder,
   extracts all `brew` formulae, filters out packages listed in
   `brew/docker-exclude`, then installs everything. The entire
   `/home/linuxbrew/.linuxbrew` prefix is carried over to the final image
   (no patchelf — scripts, Python tools, and runtimes all work natively).
2. **Final stage**: Based on `snic/nvim`, adds the Homebrew prefix to `PATH`,
   then layers zsh, tmux, dotfile configs, and TUI tool themes.

When adding a new CLI tool, just add it to the matching `Brewfile.*`. It will
automatically be included in the next Docker build. To exclude a formula from
Docker (macOS-only, hardware-dependent, or too large), add it to
`brew/docker-exclude`.

## Keybindings Cheatsheet Sync Rule

A unified keybindings reference lives at `_docs/keybindings.md`. When adding,
removing, or changing keybindings in **any** tool config, **always update the
cheatsheet** to reflect the change. This applies to:

- `ghostty/.config/ghostty/config` — Ghostty keybindings
- `tmux/.config/tmux/tmux.conf` — Tmux bindings and popup launchers
- `nvim/.config/nvim/lua/config/keymaps.lua` — NeoVim keymaps
- `nvim/.config/nvim/lua/plugins/*.lua` — Plugin-specific keybindings
- `zed/.config/zed/keymap.json` — Zed keybindings
- `zsh/conf.d/50-keybindings.zsh` — Shell keybindings
- `zsh/conf.d/40-fzf.zsh` — FZF keybindings
- `k9s/.config/k9s/plugins.yaml` — K9s plugin shortcuts

The cheatsheet groups shortcuts by tool and includes a cross-tool consistency
table at the bottom. Keep it in sync.

## Cross-Package Dependencies

Changes in one package often require updates in another. The `AGENTS.md` in
each package documents these dependencies. Key relationships:

- **`brew/Brewfile.*`** ↔ **`zsh/.config/atuin/config.toml`**: New CLI tools
  must be categorized for Atuin shell history stats. See `brew/AGENTS.md`.
  The split Brewfiles are concatenated into `~/.Brewfile` by `zsh/conf.d/15-brew.zsh`
  on shell startup, so `brew bundle` works without `--file`.
- **`nvim/`** ↔ **`zed/`**: Keybindings, LSP settings, and formatters should
  stay in sync. See `nvim/AGENTS.md` and `zed/AGENTS.md`.
