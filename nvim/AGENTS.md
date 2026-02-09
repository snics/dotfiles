# NeoVim — Agent Instructions

> **Note:** Once Claude Code supports `AGENTS.md` natively, a root-level
> `CLAUDE.md` can be removed in favor of these `AGENTS.md` files.

Instructions for AI agents working on the NeoVim configuration.
All comments, documentation, and commit messages must be in **English**.

## Config Structure

```
nvim/
  KEYMAPPING.md              # Complete keybinding reference (source of truth)
  .config/nvim/
    init.lua                 # Entry point (loads lazy.nvim)
    lazy-lock.json           # Plugin version lock
    lua/config/
      keymaps.lua            # Global keybindings
      options.lua            # Editor options
      autocmds.lua           # Autocommands
      lsp/                   # LSP configuration (see lsp/AGENTS.md)
        init.lua             # LSP orchestrator
        servers/             # Per-server configs (jsonls, yamlls, gopls, ...)
        none-ls/             # Null-ls formatters, linters, code actions
      plugins/               # Plugin specs (one per file)
```

## Related Instruction Files

- `nvim/.config/nvim/.cursorrules` — Cursor AI rules (which-key, icons, style)
- `nvim/.config/nvim/lua/config/lsp/AGENTS.md` — LSP-specific agent instructions

These files are complementary. This file covers cross-editor sync and general
rules. The others cover NeoVim-internal details.

## Keybinding Rules

### Source of Truth

`KEYMAPPING.md` is the authoritative keybinding reference. It must always
reflect the actual state of keybindings across all plugin files.

### Structure

Keybindings use `space` as leader key with the same group structure as Zed:

| Prefix | Group |
|--------|-------|
| `<leader>a` | AI (CodeCompanion) |
| `<leader>b` | Buffer |
| `<leader>c` | Code (LSP actions) |
| `<leader>d` | Debug (DAP) |
| `<leader>f` | Find (Snacks/Telescope) |
| `<leader>g` | Git (gitsigns, lazygit, diffview) |
| `<leader>l` | LSP/Lint |
| `<leader>m` | Markdown |
| `<leader>q` | Quit |
| `<leader>r` | Refactor |
| `<leader>s` | Search |
| `<leader>t` | Test (neotest) |
| `<leader>u` | UI toggles |
| `<leader>x` | Trouble/Diagnostics |
| `<leader>y` | YAML tools |

### Update Workflow

When changing any keybinding:

1. Modify the plugin file or `keymaps.lua`
2. Update `which-key.lua` (follow `.cursorrules` for format)
3. Update `KEYMAPPING.md` to reflect the change
4. Consider the Zed counterpart (see Cross-Sync below)

## Plugin Rules

- One plugin per file in `lua/config/plugins/`
- Use lazy.nvim spec format with explicit dependencies
- Lazy-load via `event`, `ft`, `cmd`, or `keys` where possible
- Document the plugin's purpose in a header comment
- English comments throughout

## LSP Rules

See `lua/config/lsp/AGENTS.md` for detailed LSP instructions. Key points:

- Modular: one file per server in `lsp/servers/`
- SchemaStore integration for JSON/YAML
- Formatters via none-ls in `lsp/none-ls/formatters/`
- Linters via none-ls in `lsp/none-ls/diagnostics/`
- Formatter preference: **Biome first, Prettier fallback** (matching Zed)

## Code Style

- 2-space indentation (Lua)
- English comments and documentation
- Follow icon guidelines from `.cursorrules` for which-key entries
- Descriptive variable names
- Logical section breaks with comment headers

## Cross-Sync with Zed

When modifying this config, always check the Zed counterpart:

- **Keybinding changed?** Check `zed/.config/zed/keymap.json` for the
  equivalent Zed binding. Propose an update or document why it's not possible.
  Known gaps are documented as `// NOT POSSIBLE` comments inside Zed's keymap.json.
- **Plugin added?** Check if a Zed extension equivalent exists
  (search Zed extension registry). Propose adding it to
  `auto_install_extensions` in Zed's settings.json.
- **LSP settings changed?** Mirror the change in Zed's `lsp` block in
  `zed/.config/zed/settings.json`.
- **Formatter settings changed?** Ensure Zed's per-language formatter
  chain matches (Biome first, Prettier fallback).

### What is NOT possible in Zed

Many NeoVim plugin features have no Zed equivalent. Known gaps are documented
as `// NOT POSSIBLE` comments in Zed's keymap.json. Major categories:

- Debug (nvim-dap) — Zed DAP is early-stage
- Refactoring (refactoring.nvim) — use LSP code actions instead
- Flash navigation — Zed has vim::PushSneak as partial replacement
- Snacks pickers — no register/mark/jump browsers
- Language-specific plugins (go.nvim, rustaceanvim) — partial via LSP actions
- YAML/K8s tools — no interactive path navigation or CRD management

Do not attempt to force-map these. Document "NOT POSSIBLE" and move on.

## Validation Checklist

After editing any config file:

- [ ] NeoVim starts without errors (`:checkhealth`)
- [ ] which-key.lua is in sync with actual keybindings
- [ ] KEYMAPPING.md is updated
- [ ] Comments are in English
- [ ] Cross-sync with Zed was considered
