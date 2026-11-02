# Neovim maintenance and validation

Validated on 2026-11-02 with Neovim 0.12.6 on macOS arm64.

## Changes

- Checked all 81 locked plugins with lazy.nvim against their configured branches; updated the 10 plugins with newer commits.
- Migrated CodeCompanion to `adapters.acp`, `adapters.http`, and `interactions`; corrected Codex's authentication method to `chat-gpt`.
- Fixed Biome, Deno, TFLint, and Kubeconform diagnostic parsing. none-ls already decodes JSON; Biome uses byte spans and nullable locations, Deno uses one-based lines and zero-based columns, and Kubeconform returns a resources array.
- Reused the maintained none-ls parsers for Oxlint and KubeLinter. Recognize modern Oxlint configuration filenames and prefer ESLint when both linter configurations exist.
- Used the formatter factory for Deno and supplied file extensions for stdin formatting/linting. Prefer Biome when both Biome and Deno configs exist.
- Restored Prettier fallback for Oxlint projects, selected a single YAML formatter, and prevented none-ls and gopls from formatting the same buffer twice.
- Kept rust-analyzer under rustaceanvim's ownership, preserved nested server capabilities, and surfaced errors in custom LSP modules.
- Resolved YAML roots for each buffer, normalized GraphQL/OpenTofu filetypes, and guarded empty YAML schema responses.
- Removed duplicate which-key metadata for the stateful Snacks toggles. Bindings remain the same.

## Validation results

All checks used an isolated configuration and plugin copy under `/tmp/dotfiles-nvim-test`. Mason's automatic installation was disabled during tests; the existing tool installations were copied for server tests. Plugin downloads and parser compilation ran separately with network access.

- Loaded every configured plugin and checked Lua syntax.
- Passed the regression suite in `tests/regression.lua`, including formatter selection, decoded diagnostic output, nullable Biome spans, YAML root configuration, and Codex ACP settings.
- Parsed output from actual Biome, Oxlint, Deno, and Kubeconform executions.
- Formatted a TypeScript buffer using Deno through the none-ls LSP client.
- Attached Lua, JSON, YAML, TypeScript, and Go language servers to real files and started Treesitter for each buffer.
- Installed the configured Treesitter parsers and their dependencies in the test environment.
- Passed `checkhealth codecompanion which-key nvim-treesitter vim.deprecated` without errors. No deprecated function calls or duplicate which-key mappings were reported.
- Passed `git diff --check`.

Some informational warnings remain: optional `markitdown` and `mini.icons` are absent (nvim-web-devicons is configured), and several mappings intentionally share prefixes. A full health check also reports optional language runtimes, LuaRocks, Rust debugger availability, and terminal image/Mermaid support. These depend on the host environment and are not covered by a clean targeted health result.

Authenticated AI requests, interactive debugger sessions, live Kubernetes access, and every language-specific project workflow were not exercised. Existing login sessions and the active `~/.config/nvim` symlink were not changed.

## Running regression checks

With the configuration installed and plugins available, run from the repository root:

```sh
nvim --headless '+luafile nvim/tests/regression.lua'
```

The suite loads the configured plugins, so ordinary plugin startup hooks can run. Use an isolated XDG configuration/data/state/cache environment when testing without changing the active installation.

## Zed synchronization

Reviewed Zed's keymap, language servers, and formatter settings. No keybindings or shared server settings changed. Biome-before-Prettier remains the common formatter policy. The YAML root fix, ACP configuration, none-ls output parsing, and dynamic which-key descriptions are Neovim-specific and need no Zed changes.

The updated lockfile and fixes are in this worktree. Deploy the configuration through the repository's usual Stow workflow, then run `:Lazy restore` to install the exact tested plugin commits.
