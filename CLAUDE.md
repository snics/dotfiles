# Dotfiles — Claude Code Instructions

Project-specific instructions for Claude Code working on this dotfiles repository.
For cross-platform AI agent instructions, see `AGENTS.md` in the repo root and
in each package subdirectory (`nvim/AGENTS.md`, `zed/AGENTS.md`).

## Repository Structure

This is a GNU Stow-managed dotfiles repository. Each top-level directory is a
stow package that symlinks into `$HOME`:

```
brew/       → Brewfile (Homebrew packages)
claude/     → ~/.claude/ (Claude Code user config)
cursor/     → Cursor editor config
ghostty/    → Ghostty terminal config
git/        → ~/.config/git/ (gitconfig, aliases)
k9s/        → ~/.config/k9s/
lazygit/    → ~/.config/lazygit/
nvim/       → ~/.config/nvim/ (NeoVim)
opencode/   → OpenCode AI config
tmux/       → ~/.config/tmux/
zed/        → ~/.config/zed/ (Zed editor)
zsh/        → Zsh shell config (conf.d/, functions/, themes/)
```

## Commit Conventions

- Use [Conventional Commits](https://www.conventionalcommits.org/) with gitmoji prefix
- Format: `<gitmoji> <type>(scope): <description>`
- Examples:
  - `🔧 fix(zsh): resolve Alt+C binding on macOS`
  - `✨ feat(nvim): add Go debug keybindings`
  - `🔧 chore(brew): add new CLI tools to Brewfile`
- Language: English for all commits, comments, and documentation

## Configuration Dependencies

### Brewfile → Atuin config.toml

**Critical**: When CLI tools are added to or removed from `brew/Brewfile`, the
Atuin stats configuration at `zsh/.config/atuin/config.toml` must be updated.

#### When to update

After ANY change to `brew/Brewfile` that adds or removes a CLI tool (formula or
cask that provides a CLI binary), evaluate the tool and update the `[stats]`
section in `zsh/.config/atuin/config.toml`.

#### How to categorize a new CLI tool

Run `<tool> --help` or `<tool> help` to determine if it uses subcommands.

1. **Has subcommands** (e.g., `kubectl get`, `docker run`, `brew install`):
   → Add to `common_subcommands` in the appropriate category comment block.

2. **Is a TUI / interactive full-screen app** (e.g., k9s, lazygit, btop):
   → Add to `ignored_commands` under "Editors & TUIs".

3. **Is an AI agent / interactive session** (e.g., claude, codex):
   → Add to `ignored_commands` under "AI agents".

4. **Is trivial / noise** (e.g., single-purpose, no useful stats):
   → Add to `ignored_commands` under the appropriate category.

5. **Is a wrapper** (e.g., time, sudo, nohup):
   → Add to `common_prefix`.

6. **Is a regular tool with no subcommands** (e.g., jq, ripgrep, fd):
   → No atuin config change needed. These are tracked as-is.

#### Current categories in common_subcommands

```toml
# Package managers:  brew, npm, yarn, pnpm, pip, cargo, go, rustup, uv, mas
# Container tools:   docker, docker-compose, podman, podman-compose, skopeo, trivy, reg
# Kubernetes:        kubectl, k, helm, minikube, kind, istioctl, cmctl, kompose,
#                    kubescape, kubeshark, polaris
# Cloud & Infra:     aws, gcloud, hcloud, coder, oc, rancher, rke, limactl
# Dev tools:         git, gh, glab, dlv, op, sesh, mc
# IaC:               terraform, tofu
```

#### Example: Adding a new tool

If `brew/Brewfile` adds `brew "vault"`:
1. Run `vault --help` → has subcommands (read, write, list, login, etc.)
2. Add `"vault"` to `common_subcommands` under `# Cloud & Infra`
3. Commit both files together

### Brewfile → zsh completions

If a new CLI tool provides zsh completions via `bashcompinit` (like `tofu` or
`mc`), add the completion setup to `zsh/conf.d/90-completions.zsh`.

## Zsh Configuration

### conf.d/ Loading Order

```
.zshrc sources:
  1. conf.d/00-init.zsh       ← Explicit (before Zimfw)
  2. Homebrew shellenv
  3. ~/.secrets
  4. Zimfw init               ← Plugin manager
  5. conf.d/[1-9]*.zsh        ← Glob loop (after Zimfw)
```

`00-init.zsh` contains environment variables and zstyles that plugins read
during initialization. Everything else loads after Zimfw.

### Numbering Scheme

| Range | Purpose |
|-------|---------|
| 00    | Pre-Zimfw init (explicit source) |
| 10    | PATH |
| 20    | Aliases |
| 30-40 | Tool configs (fzf-tab, fzf) |
| 50    | Keybindings |
| 60    | Atuin (history) |
| 70    | Functions auto-loader |
| 90    | Completions |

Gaps are intentional — they allow inserting new configs without renumbering.
