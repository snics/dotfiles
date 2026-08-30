# Git Package — Agent Instructions

Rules for working on the Git configuration.

## Config Structure

```
git/
├── .gitconfig                # Main config (aliases, delta, GPG, hooks, colors)
├── catppuccin.gitconfig      # Delta pager themes (all 4 Catppuccin flavors)
├── hooks/
│   └── format-staged         # Pre-commit dispatcher (oxfmt/dprint/oxlint/stylua/yamllint)
├── .config/git/
│   ├── ignore                # Global gitignore rules
│   ├── .gitignore            # Git's own ignore
│   └── .gitattributes        # EOL and merge driver settings
└── .stow-local-ignore        # Ignores catppuccin.gitconfig, AGENTS.md, hooks/
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

Delta stays the global `core.pager` — do not replace it with `hunk pager`.
Hunk is opt-in via the `hd`/`hs` aliases and the difftool slot (below).

## Difftool (Hunk)

`git difftool` opens [Hunk](https://github.com/modem-dev/hunk), the review
TUI from the `hunk/` stow package (`diff.tool = hunk`). Git invokes it once
per file. For a whole-changeset stream use `git hd` / `git hs` or `hunk diff`
directly. Requires `hunk` from `brew/Brewfile.30-git`.

## GPG Signing

- Commit signing enabled (`commit.gpgsign = true`)
- Uses `gpg2` program
- Signing key set in `[user]` section
- Annotated tag signing: disabled (`tag.forceSignAnnotated = false`)

## Aliases

50+ aliases defined in `[alias]`. Each alias has an inline comment.
When adding new aliases, follow the same pattern: short name + comment.

## Editor and Merge Tool

- Editor: `nvim`
- Merge tool: `nvimdiff`
- Conflict style: `diff3`

## Config-Based Hooks (Git 2.54+)

`.gitconfig` defines pre-commit hooks under `[hook "<name>"]` sections — the
new mechanism introduced in Git 2.54 (October 2025). Unlike `core.hooksPath`,
these hooks are additive: per-repo `.git/config` can register additional hooks
without overriding the global ones, and traditional `.git/hooks/*` scripts
still run last.

### Active global hooks

| Hook | Tool | Trigger | Behavior |
|------|------|---------|----------|
| `oxfmt` | oxfmt | pre-commit | Formats staged JS/TS/JSON*/MD/MDX/YAML/TOML/CSS/HTML/Vue/GraphQL, re-stages |
| `dprint` | dprint | pre-commit | Formats staged **Dockerfiles** only, re-stages |
| `oxlint` | oxlint | pre-commit | Lints staged JS/TS, blocks commit on errors |
| `stylua` | stylua | pre-commit | Formats staged Lua, re-stages |
| `yamllint` | yamllint | pre-commit | Lints staged YAML against per-repo `.yamllint`, blocks commit on errors |

All five dispatch through `git/hooks/format-staged <tool>`.

### Scope split: oxfmt vs dprint

`oxfmt` (Oxc project, Rust, Beta) is the primary multi-format formatter and
covers nearly everything dprint used to handle. `dprint` is kept **only** for
Dockerfiles, since oxfmt has no Dockerfile plugin. Both hooks can run in the
same commit without overlap because the extension filters are disjoint.

KYAML (Kubernetes 1.34+ YAML subset) is **not** auto-formatted: no Rust tool
understands the KYAML profile, and the reference tool (`kubectl -o kyaml`)
is Go-based and Kubernetes-specific. For K8s repos that enforce KYAML, add
a per-repo hook calling `kubectl -o kyaml` rather than enabling oxfmt on
`.yaml`.

### Opt-in semantics

Each hook is **opt-in per repository** — it only acts if the target repo has
a tool config file:

| Tool | Required config in repo |
|------|-------------------------|
| oxfmt | `.oxfmtrc.json`, `.oxfmtrc.jsonc`, `oxfmt.config.ts` |
| dprint | `dprint.json`, `.dprint.json`, `dprint.jsonc`, `.dprint.jsonc` |
| oxlint | `.oxlintrc.json`, `oxlintrc.json` |
| stylua | `stylua.toml`, `.stylua.toml` |
| yamllint | `.yamllint`, `.yamllint.yaml`, `.yamllint.yml` |

Without the config file, the hook exits silently. An empty `.oxfmtrc.json`
(`{}`) is enough to opt a repo into oxfmt with sensible defaults; `dprint init`
is the typical opt-in path for the Dockerfile hook (config must declare the
Dockerfile plugin). The yamllint opt-in is typically a minimal `.yamllint`
that copies the `yamllint/.yamllint.example` template from the dotfiles —
see `yamllint/AGENTS.md` for the default rule set and the recommended
"forbid non-empty flow sequences" stance for K8s manifests.

### Partially-staged file safety

The dispatcher only re-stages files whose entire working-tree state is
already staged (no unstaged hunks). Files with mixed staged/unstaged changes
are skipped with a warning, since blindly re-staging them would pull
unstaged work into the commit.

### Inspecting and managing hooks

```sh
git hook list pre-commit                    # Show all configured hooks
git config hook.dprint.enabled false        # Disable a specific hook
git config --unset hook.dprint.enabled      # Re-enable
git hook run pre-commit                     # Manually fire the hook chain
```

### Adding a new hook

1. Add a tool entry in `git/hooks/format-staged` (case branch with config
   detection, extension regex, and run command).
2. Register it in `git/.gitconfig` as a new `[hook "<name>"]` block.
3. If the tool is a new CLI, follow the Brewfile sync rules (`brew/AGENTS.md`).
