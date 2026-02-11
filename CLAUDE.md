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

The Docker images (`_images/devenv/Dockerfile`) install a **subset** of brew
tools directly via `brew install` in a multi-stage build — they do **not** use
`brew bundle` or the split Brewfiles. The `15-brew.zsh` is copied into the
container but is a no-op since `brew/` doesn't exist there. When adding a new
CLI tool to both host and container, update the matching `Brewfile.*` **and**
the Dockerfile's `brew install` list.

## Cross-Package Dependencies

Changes in one package often require updates in another. The `AGENTS.md` in
each package documents these dependencies. Key relationships:

- **`brew/Brewfile.*`** ↔ **`zsh/.config/atuin/config.toml`**: New CLI tools
  must be categorized for Atuin shell history stats. See `brew/AGENTS.md`.
  The split Brewfiles are concatenated into `~/.Brewfile` by `zsh/conf.d/15-brew.zsh`
  on shell startup, so `brew bundle` works without `--file`.
- **`nvim/`** ↔ **`zed/`**: Keybindings, LSP settings, and formatters should
  stay in sync. See `nvim/AGENTS.md` and `zed/AGENTS.md`.
