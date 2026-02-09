# Dotfiles — Claude Code Project Instructions

> **Migration notice:** This file exists because Claude Code does not yet support
> the `agents.md` open standard. Once Claude Code reads `agents.md` files natively,
> delete this file and rely solely on `zed/agents.md` and `nvim/agents.md`.

## Project Overview

GNU Stow-based dotfiles repository managing configuration for multiple tools.
Each top-level directory is a stow package that symlinks into `$HOME`.

Key directories:

| Directory | Purpose |
|-----------|---------|
| `zed/` | Zed editor (settings, keymap, tasks, snippets) |
| `nvim/` | NeoVim editor (init.lua, lazy.nvim plugins, LSP) |
| `claude/` | Claude Code CLI (plugins, MCP servers) |
| `ghostty/` | Ghostty terminal emulator |
| `zsh/` | Zsh shell (aliases, plugins, prompt) |
| `git/` | Git config and global ignores |
| `brew/` | Homebrew Brewfile |
| `tmux/` | Tmux configuration |

## Language & Style

- All comments, documentation, and commit messages in **English**.
- Commit messages use emoji prefix: `feat:`, `fix:`, `chore:`, `refactor:` etc.
- Atomic commits — one logical change per commit.

## Cross-Editor Sync (Zed <-> NeoVim)

Both Zed and NeoVim share the same keybinding philosophy (space as leader,
identical group structure) and overlap in LSP servers, formatters, and linters.

**When modifying either editor's config, always consider the counterpart.**

### Keybindings

- When adding or changing a keybinding in `zed/.config/zed/keymap.json`,
  check `nvim/KEYMAPPING.md` and propose the equivalent NeoVim binding.
- When adding or changing a keybinding in NeoVim (any plugin or `keymaps.lua`),
  check `zed/.config/zed/keymap.json` and propose the equivalent Zed binding.
- Use `zed/KEYMAPPING-ANALYSIS.md` as the reference for what is mappable
  between editors and what is not.
- If a binding cannot be mapped, document it as a `// NOT POSSIBLE` comment
  (Zed) or a Lua comment (NeoVim) with the reason.

### Plugins / Extensions

- When adding a NeoVim plugin, check if a Zed extension equivalent exists
  and propose adding it to `auto_install_extensions` in Zed's settings.json.
- When adding a Zed extension, check if a NeoVim plugin equivalent exists
  and propose adding it via lazy.nvim.
- If no equivalent exists, document this clearly.

### LSP / Formatters / Linters

- Keep LSP server settings in sync: same initialization options, same
  enabled features (e.g. rust-analyzer clippy, gopls placeholders).
- Formatter preference: **Biome first, Prettier fallback** (both editors).
- Linter configuration should match where possible.

### Tasks

- Zed uses `tasks.json`, NeoVim uses terminal commands or overseer.nvim.
- When adding a Zed task, document the equivalent shell command for NeoVim.

## Editor-Specific Instructions

For detailed rules on each editor's configuration:

- **Zed:** see `zed/agents.md`
- **NeoVim:** see `nvim/agents.md`
- **NeoVim LSP:** see `nvim/.config/nvim/lua/config/lsp/AGENTS.md`
- **NeoVim (Cursor):** see `nvim/.config/nvim/.cursorrules`
