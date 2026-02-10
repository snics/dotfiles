# Git Package — Agent Instructions

Rules for working on the Git configuration.

## Config Structure

```
git/
├── .gitconfig                # Main config (aliases, delta, GPG, colors)
├── catppuccin.gitconfig      # Delta pager themes (all 4 Catppuccin flavors)
├── .config/git/
│   ├── ignore                # Global gitignore rules
│   ├── .gitignore            # Git's own ignore
│   └── .gitattributes        # EOL and merge driver settings
└── .stow-local-ignore        # Ignores catppuccin.gitconfig, AGENTS.md
```

## Include Chain

`.gitconfig` uses two `[include]` directives:

1. `path = ~/.dotfiles/git/catppuccin.gitconfig` — Delta theme (absolute path)
2. `path = .gitconfig.user` — Local overrides, **not tracked** (user-specific)

The `.gitconfig.user` include must remain at the end so local overrides win.

## Pager

Delta with Catppuccin Mocha theme. Requires `delta` from `brew/Brewfile`.

- Side-by-side diff enabled
- Line numbers enabled
- Navigate mode enabled (n/N to jump between files)

`catppuccin.gitconfig` contains themes for all 4 flavors. Only edit this file
to update the Delta color scheme — do not add other git settings here.

## GPG Signing

- Commit signing enabled (`commit.gpgsign = true`)
- Uses `gpg2` program
- Signing key set in `[user]` section
- Annotated tag signing: disabled (`tag.forceSignAnnotated = false`)

## Aliases

50+ aliases defined in `[alias]`. Each alias has an inline comment.
When adding new aliases, follow the same pattern: short name + comment.

## Editor and Merge Tool

- Editor: `vim`
- Merge tool: `mvimdiff` (with Fugitive integration)
- Conflict style: `diff3`
