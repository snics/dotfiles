# Dotfiles — Agent Instructions

Instructions for AI agents working on this dotfiles repository.
All comments, documentation, and commit messages must be in **English**.

## Repository Layout

GNU Stow-managed dotfiles. Each top-level directory is a stow package that
symlinks into `$HOME`. Run `stow <package>` from the repo root to install.

## Commit Conventions

- Conventional Commits with gitmoji: `<emoji> <type>(scope): <description>`
- Scopes match package directories: `zsh`, `nvim`, `zed`, `brew`, `git`, etc.

## Configuration Dependencies

When modifying `brew/Brewfile` (adding/removing CLI tools), also update:

1. **`zsh/.config/atuin/config.toml`** — `[stats]` section:
   - Tools with subcommands → `common_subcommands`
   - TUIs and interactive apps → `ignored_commands`
   - Wrappers (sudo-like) → `common_prefix`
   - Regular tools (no subcommands) → no change needed

2. **`zsh/conf.d/90-completions.zsh`** — if the tool needs `bashcompinit`.

See `CLAUDE.md` for detailed categorization rules.

## Package-Specific Instructions

- `nvim/AGENTS.md` — NeoVim config rules, keybindings, cross-sync with Zed
- `zed/AGENTS.md` — Zed editor config rules, keybindings, cross-sync with NeoVim
