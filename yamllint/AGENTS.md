# Yamllint Package — Agent Instructions

Rules for the global yamllint integration that sits next to the
`oxfmt`/`dprint`/`oxlint`/`stylua` pre-commit hooks in `~/.dotfiles/git/`.

## Structure

```
yamllint/
├── .yamllint.example   # Template — copy into a repo root as `.yamllint`
│                       # to opt the repo into the yamllint pre-commit hook.
└── AGENTS.md           # This file.
```

This package is **not stowed** into `$HOME` — there is no canonical
"global yamllint config" because yamllint's auto-discovery walks from
the current dir upward looking for `.yamllint`, `.yamllint.yaml`, or
`.yamllint.yml`. The template lives here so repos copy a known starting
point rather than each inventing one.

## Hook wiring

The hook entry lives in `~/.dotfiles/git/.gitconfig`:

```ini
[hook "yamllint"]
  event = pre-commit
  command = ~/.dotfiles/git/hooks/format-staged yamllint
```

The dispatcher in `~/.dotfiles/git/hooks/format-staged` is the single
source of truth for the yamllint case: it opts in based on
`.yamllint`/`.yamllint.yaml`/`.yamllint.yml` presence, filters staged
files to `*.yaml`/`*.yml`, and runs `yamllint <files>` (lint-only,
non-zero exit blocks the commit). See `git/AGENTS.md` for the full
dispatcher behaviour.

## Default rule stance

`.yamllint.example` ships only two rules: `brackets: forbid: non-empty`
and `braces: forbid: non-empty`. Together they enforce block-style for
non-empty list and mapping literals while preserving the canonical
empty forms `[]` and `{}` that kubectl emits for cluster-scoped
resources with no entries.

Rationale: in Kubernetes RBAC and other manifests, mixing flow style
`[a, b, c]` with block-style mappings is jarring, diff-unfriendly, and
inconsistent with `kubectl get … -o yaml` output. The project-wide
default is block-style; specific repos can extend the rule set as
their needs grow.

## Adding more rules

yamllint's full rule catalogue is at <https://yamllint.readthedocs.io/>.
Rules deliberately **not** enabled by default:

- `line-length` — chart-rendered Helm values often exceed 80 cols.
- `indentation` — many manifests mix 2- and 4-space lists.
- `truthy` — Helm templates pre-render `true`/`false` quoted.
- `comments-indentation` — chart-rendered output is inconsistent.
- `document-start` — `---` is optional everywhere except when
  concatenating documents.
- `key-duplicates` — could enable safely; deferred until the first
  repo opts in.

When a repo's `.yamllint` adds rules beyond the defaults, copy the
explicit rule line into the file (no `extends:` chain) so the
repo-local config is self-contained.

## Brewfile

`yamllint` lives in `brew/Brewfile.20-dev-tools` alongside `oxfmt`,
`oxlint`, `shellcheck`, `stylua`. New machines pick it up via the
standard Brewfile install.

## Opting a repo in

```sh
cd <repo-root>
cp ~/.dotfiles/yamllint/.yamllint.example .yamllint
git add .yamllint
git commit -m "chore: opt in to yamllint pre-commit hook"
```

That's it — the global hook picks up the opt-in marker on the next
commit and runs yamllint against any staged `*.yaml`/`*.yml`.
