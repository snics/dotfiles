# Lazygit Package — Agent Instructions

Rules for working on the Lazygit configuration.

## Config Structure

```
lazygit/
├── .config/lazygit/
│   └── config.yml         # Main config (UI, git, keybindings, theme)
├── themes/mocha/          # 13 Catppuccin Mocha color variants (read-only)
│   ├── blue.yml, green.yml, mauve.yml, ...
│   └── [reference themes — do NOT edit]
└── .stow-local-ignore     # Ignores themes/*, AGENTS.md
```

## Theme

Catppuccin Mocha with mauve accent. Colors are hardcoded in `config.yml`
under `gui.theme`. Key color mappings:

| Element              | Color   | Hex       |
|----------------------|---------|-----------|
| Active border        | Mauve   | `#cba6f7` |
| Inactive border      | Subtext0| `#a6adc8` |
| Selected line bg     | Surface0| `#313244` |
| Cherry-pick bg       | Surface1| `#45475a` |
| Unstaged changes     | Red     | `#f38ba8` |
| Default foreground   | Text    | `#cdd6f4` |

The `themes/mocha/` directory contains reference variants — do not edit them.
They are excluded from Stow via `.stow-local-ignore`.

## Key Settings

- `git.mainBranches`: `master`, `main` — used for branch display
- `git.autoFetch`: enabled (60s interval)
- `git.autoRefresh`: enabled (10s interval)
- `git.parseEmoji`: disabled — gitmoji renders as `:rocket:` not as icons
- `gui.border`: rounded
- `gui.nerdFontsVersion`: empty (no icons)

## Keybindings

Vim-inspired defaults (hjkl navigation). Custom overrides are in the
`keybinding` section of `config.yml`. Do not remove the `optionMenu: <disabled>`
entry — it prevents accidental menu opens.
