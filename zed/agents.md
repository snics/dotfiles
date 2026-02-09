# Zed Editor — Agent Instructions

Instructions for AI agents working on the Zed editor configuration.

## Config Files

| File | Purpose |
|------|---------|
| `.config/zed/settings.json` | Editor settings, languages, LSP, extensions |
| `.config/zed/keymap.json` | Vim-mode keybindings (space-leader) |
| `.config/zed/tasks.json` | Build/test/lint task definitions |
| `.config/zed/snippets/` | Code snippets per language |
| `KEYMAPPING-ANALYSIS.md` | NeoVim-to-Zed keybinding reference |

## Keybinding Rules

### Structure

Keymap uses Zed vim mode with `space` as leader key. Bindings are organized by context:

1. `vim_mode == insert` — insert mode shortcuts
2. `vim_mode == normal` — leader key groups (space + prefix)
3. `vim_mode == visual` — visual mode actions
4. `Terminal` — terminal pane navigation
5. `Workspace` — global shortcuts (all modes)

### Leader Key Groups

| Prefix | Group | Examples |
|--------|-------|---------|
| `space a` | AI | agent panel, inline assist, edit predictions |
| `space b` | Buffer | close, close others |
| `space c` | Code | actions, rename, format, blame |
| `space f` | Find | files, search, buffers |
| `space g` | Git | status, branches, hunks |
| `space l` | LSP | diagnostics, restart server |
| `space m` | Markdown | preview |
| `space q` | Quit | close buffer |
| `space s` | Search | grep, symbols, replace |
| `space t` | Tests | run, rerun, spawn |
| `space u` | UI | wrap, line numbers, hints |
| `space x` | Trouble | diagnostics, references |
| `space tab` | Tabs | new, close, navigate |

### Action Name Verification

Always verify Zed action names are current. Zed frequently renames actions.
Known deprecated actions (do NOT use):

| Deprecated | Current |
|-----------|---------|
| `editor::AcceptInlineCompletion` | `editor::AcceptEditPrediction` |
| `editor::AcceptPartialInlineCompletion` | `editor::AcceptNextWordEditPrediction` |
| `editor::ToggleInlineCompletions` | `editor::ToggleEditPrediction` |
| `assistant::ToggleFocus` | `agent::ToggleFocus` |
| `assistant::NewThread` | `agent::NewThread` |
| `assistant::QuoteSelection` | `agent::AddSelectionToThread` |
| `agent::Open` | `agent::ToggleFocus` |
| `branches::OpenRecent` | `git::Branch` |
| `editor::ToggleHunkDiff` | `editor::ToggleSelectedDiffHunks` |
| `editor::ToggleGitBlame` | `git::Blame` |
| `lsp::RestartLanguageServer` | `editor::RestartLanguageServer` |

When unsure, verify against the Zed source at `zed-industries/zed` on GitHub,
specifically `assets/keymaps/default-macos.json` and `crates/zed_actions/src/lib.rs`.

### Context Requirements

- Actions like `project_panel::Rename` only work in `ProjectPanel` context.
- `vim::PushSneak` needs `VimControl && !menu` context.
- Terminal bindings need `Terminal` context.
- Always check which context an action requires before mapping it.

## Extension Rules

- Extensions are managed via `auto_install_extensions` in settings.json.
- Verify extension IDs exist before adding (check Zed extension registry).
- Common mistakes: `cappuccino` vs `catppuccin`, underscores vs hyphens.

## Formatter Configuration

Formatter preference chain for JS/TS/JSX/TSX/CSS/JSON/JSONC/GraphQL:

1. **Biome** (language server) — with `require_config_file: true`
2. **Prettier** (external fallback) — `prettier --stdin-filepath {buffer_path}`

This is configured per-language in the `languages` block of settings.json.
Biome also provides `code_actions_on_format` for auto-fix and import organization.

For all other languages, use the default language server formatter.

## Language Settings

Per-language overrides go in the `languages` block of settings.json.
Key conventions:

- Default `tab_size: 2` for most languages
- `tab_size: 4` with `hard_tabs: true` for Go, Rust, Python, Zig
- `format_on_save: "on"` globally
- `preferred_line_length: 80` default, `100` for Go/Rust

## Task Conventions

### Package Manager Detection (JS/TS)

All JS/TS tasks detect the project's package manager in this priority:

```
pnpm (pnpm-lock.yaml) > bun (bun.lockb/bun.lock) > deno (deno.json/deno.jsonc) > npm (fallback)
```

### Terraform / OpenTofu Detection

Default to `tofu`. Only use `terraform` when `.terraform-version` file exists:

```sh
if [ -f .terraform-version ]; then terraform ...; else tofu ...; fi
```

### Labels

- Go tasks: `go:` prefix
- Rust tasks: `rust:` prefix
- JS/TS tasks: `js/ts:` prefix
- Docker tasks: `docker:` prefix

## Cross-Sync with NeoVim

When modifying this config, always check the NeoVim counterpart:

- **Keybindings changed?** Check `nvim/KEYMAPPING.md` for the equivalent
  NeoVim binding. Propose an update or document why it's not possible.
- **Extension added?** Check if a NeoVim plugin equivalent exists
  (search lazy.nvim ecosystem). Propose adding it.
- **LSP settings changed?** Mirror the change in
  `nvim/.config/nvim/lua/config/lsp/servers/`.
- **Formatter settings changed?** Ensure NeoVim's none-ls/conform config
  uses the same formatter preference.

Reference `KEYMAPPING-ANALYSIS.md` for the full mapping between editors.

## Validation Checklist

After editing any config file:

- [ ] JSON syntax is valid (no trailing commas in wrong places, JSONC comments ok)
- [ ] Action names are current (not deprecated)
- [ ] Extension IDs are correct
- [ ] Comments are in English
- [ ] Cross-sync with NeoVim was considered
