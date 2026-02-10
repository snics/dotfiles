# Dotfiles — Agent Instructions

Instructions for AI agents working on this dotfiles repository.
All comments, documentation, and commit messages must be in **English**.

## Repository Layout

GNU Stow-managed dotfiles. Each top-level directory is a stow package that
symlinks into `$HOME`. Run `stow <package>` from the repo root to install.

```
brew/        → Brewfile (Homebrew packages)
claude/      → Claude Code user config
ghostty/     → Ghostty terminal
git/         → Git config + aliases
k9s/         → Kubernetes TUI
lazygit/     → Lazygit config
nvim/        → NeoVim config
opencode/    → OpenCode AI config
tmux/        → tmux config
zed/         → Zed editor config
zsh/         → Zsh shell (conf.d/, functions/, themes/)
```

## Commit Conventions

Conventional Commits with gitmoji: `<emoji> <type>(scope): <description>`

## Cross-Package Dependencies

Changes in one package may require updates in another:

- **`brew/Brewfile`** ↔ **`zsh/.config/atuin/config.toml`**: CLI tool changes
  require Atuin stats config updates. See `brew/AGENTS.md`.
- **`nvim/`** ↔ **`zed/`**: Keybindings, LSP, formatters stay in sync.

## Package-Specific Instructions

- `brew/AGENTS.md` — Brewfile rules and sync obligations
- `zsh/AGENTS.md` — Zsh config structure, Atuin maintenance
- `nvim/AGENTS.md` — NeoVim config, keybindings, Zed cross-sync
- `zed/AGENTS.md` — Zed editor config, keybindings, NeoVim cross-sync
