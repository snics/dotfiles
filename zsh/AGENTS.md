# Zsh Package — Agent Instructions

Rules for working on the Zsh shell configuration.

## Config Structure

```
zsh/
├── .zshrc                    # Entry point (orchestrates loading order)
├── .zshenv                   # Minimal env (non-interactive shells)
├── .zprofile                 # Login shell setup
├── .stow-local-ignore        # Stow ignore (themes/, conf.d/, functions/)
├── conf.d/
│   ├── 00-init.zsh           # Pre-Zimfw: ENV + zstyles (explicit source)
│   ├── 10-path.zsh           # PATH additions
│   ├── 20-aliases.zsh        # Shell aliases
│   ├── 30-fzf-tab.zsh       # fzf-tab format + directory preview
│   ├── 40-fzf.zsh           # fzf Ctrl+T / Alt+C previews
│   ├── 50-keybindings.zsh   # Emacs mode + macOS Alt+C fix
│   ├── 60-atuin.zsh         # Atuin init + autosuggestions strategy
│   ├── 70-functions.zsh     # Functions auto-loader
│   ├── 80-gnu-generic.zsh  # _gnu_generic fallback for tools without completions
│   └── 90-completions.zsh   # bashcompinit + gcloud
├── functions/                # Auto-loaded shell functions (one per file)
├── themes/                   # Syntax highlighting themes
└── .config/
    ├── atuin/config.toml     # Atuin shell history config
    ├── bat/                  # bat (cat replacement) config
    ├── btop/                 # btop system monitor config
    ├── starship.toml         # Starship prompt config
    └── yazi/                 # yazi file manager config
```

## Loading Order

```
.zshrc:
  1. conf.d/00-init.zsh       ← Explicit source (before Zimfw)
  2. Homebrew shellenv
  3. ~/.secrets
  4. Zimfw init               ← Plugin manager
  5. conf.d/[1-9]*.zsh        ← Glob loop (after Zimfw, sorted by number)
```

`00-init.zsh` is the ONLY file sourced before Zimfw. It contains environment
variables and zstyles that plugins read during initialization.

## conf.d/ Numbering Scheme

| Range | Purpose |
|-------|---------|
| 00    | Pre-Zimfw init (explicit source, not in glob) |
| 10    | PATH |
| 20    | Aliases |
| 30-40 | Tool configs (fzf-tab, fzf) |
| 50    | Keybindings |
| 60    | Atuin (history) |
| 70    | Functions auto-loader |
| 80    | _gnu_generic fallback completions |
| 90    | Completions (bashcompinit + gcloud) |

Gaps are intentional — they allow inserting new configs without renumbering.

## Atuin Config Maintenance

The file `.config/atuin/config.toml` contains a `[stats]` section with three
arrays that must be kept in sync with installed tools:

### common_subcommands

Tools where subcommands are tracked separately (e.g., "kubectl get" vs
"kubectl apply"). Organized by category:

```
# Package managers, Container tools, Kubernetes, Cloud & Infra, Dev tools, IaC
```

### ignored_commands

Commands excluded from `atuin stats` (TUIs, editors, AI agents, trivial
commands). Does NOT affect history storage or autosuggestions — only stats.

### common_prefix

Wrapper commands stripped for accurate counting (e.g., `sudo docker ps`
counts as `docker ps`).

### Sync Obligation

When `brew/Brewfile` changes (tools added/removed), this file must be updated.
See `brew/AGENTS.md` for categorization rules and examples.

The reverse also applies: if atuin config is updated with a new tool, verify
that tool is present in the Brewfile.
