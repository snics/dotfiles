# Dotfiles — Claude Code Instructions

Project-specific instructions for Claude Code working on this dotfiles repository.

## Repository Structure

GNU Stow-managed dotfiles. Each top-level directory is a stow package that
symlinks into `$HOME` via `stow <package>` from the repo root.

```
_install/    → Setup scripts (not a stow package)
asdf/        → asdf version manager plugins
brew/        → Brewfile (Homebrew packages)
claude/      → ~/.claude/ (Claude Code user config, MCP servers)
cursor/      → Cursor editor config
docs/        → Documentation and screenshots (not a stow package)
ghostty/     → ~/.config/ghostty/ (terminal emulator)
git/         → ~/.config/git/ + ~/.gitconfig
k9s/         → ~/.config/k9s/ (Kubernetes TUI)
lazygit/     → ~/.config/lazygit/
macOS/       → macOS system settings scripts (not a stow package)
nvim/        → ~/.config/nvim/ (NeoVim)
obsidian/    → Obsidian vault structure
opencode/    → ~/.config/opencode/ (AI coding agent)
planning/    → Project planning docs (not a stow package)
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

## Cross-Package Dependencies

Changes in one package often require updates in another. The `AGENTS.md` in
each package documents these dependencies. Key relationships:

- **`brew/Brewfile`** ↔ **`zsh/.config/atuin/config.toml`**: New CLI tools
  must be categorized for Atuin shell history stats. See `brew/AGENTS.md`.
- **`nvim/`** ↔ **`zed/`**: Keybindings, LSP settings, and formatters should
  stay in sync. See `nvim/AGENTS.md` and `zed/AGENTS.md`.
