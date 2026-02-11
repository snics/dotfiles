# Brew Package — Agent Instructions

Rules for modifying the Homebrew Brewfiles and keeping dependent configs in sync.

## Brewfile Structure

The `brew/` directory contains split Brewfiles with numeric prefixes that
control load order (taps must come first). The files are concatenated into
`~/.Brewfile` by `zsh/conf.d/15-brew.zsh` on shell startup.

```
Brewfile.00-taps        Tap repositories (must be first)
Brewfile.10-cli-core    Core CLI tools (shell, editor, file utils)
Brewfile.20-dev-tools   Languages, runtimes, package managers
Brewfile.30-git         Git and version control
Brewfile.40-cloud-k8s   Cloud, Kubernetes, infrastructure
Brewfile.50-containers  Docker, Podman, container security
Brewfile.55-k8s-security  Kubernetes security and compliance
Brewfile.60-security    Security and networking tools
Brewfile.65-ai          AI coding agents
Brewfile.70-media       Media, image, document tools
Brewfile.75-compression Compression and archiving
Brewfile.78-webfonts    Web font tools
Brewfile.80-misc        Miscellaneous CLI tools
Brewfile.85-casks       macOS GUI applications
Brewfile.87-quicklook   Quick Look plugins
Brewfile.88-fonts       Fonts
Brewfile.90-mas         Mac App Store apps
Brewfile.99-hardware    Keyboards and peripherals
```

### Adding a new tool

Add the entry to the appropriate category file. When adding a tap-specific
formula, ensure the tap is declared in `Brewfile.00-taps`.

### CLI workflow

All standard `brew bundle` commands work without `--file` because
`HOMEBREW_BUNDLE_FILE=~/.Brewfile` is set in `zsh/conf.d/00-init.zsh`.
The `~/.Brewfile` is auto-regenerated when any source file changes.

Additional justfile/Makefile targets: `brew-install`, `brew-list`,
`brew-check`, `brew-cleanup`, `brew-dump`, `brew-edit`.

## Sync Obligation: Brewfile ↔ Atuin Config

**When adding or removing a CLI tool in `Brewfile`, you MUST also update
`zsh/.config/atuin/config.toml`** in the `[stats]` section.

Both files must be committed together in the same commit.

### How to categorize a new CLI tool

Run `<tool> --help` or `<tool> help` to check if it uses subcommands.

| Tool type | Action | Target in config.toml |
|-----------|--------|-----------------------|
| Has subcommands (e.g. `kubectl get`, `docker run`) | Add | `common_subcommands` |
| TUI / full-screen interactive (e.g. k9s, btop) | Add | `ignored_commands` |
| AI agent / interactive session (e.g. claude, codex) | Add | `ignored_commands` |
| Trivial / noise (e.g. single-purpose, no useful stats) | Add | `ignored_commands` |
| Wrapper command (e.g. time, sudo, nohup) | Add | `common_prefix` |
| Regular tool without subcommands (e.g. jq, rg, fd) | None | No config change needed |

### Current common_subcommands categories

Place new entries in the correct category comment block:

```
# Package managers:  brew, npm, yarn, pnpm, pip, cargo, go, rustup, uv, mas
# Container tools:   docker, docker-compose, podman, podman-compose, skopeo, trivy, reg
# Kubernetes:        kubectl, k, helm, minikube, kind, istioctl, cmctl, kompose,
#                    kubescape, kubeshark, polaris
# Cloud & Infra:     aws, gcloud, hcloud, coder, oc, rancher, rke, limactl
# Dev tools:         git, gh, glab, dlv, op, sesh, mc
# IaC:               terraform, tofu
```

### Example

Adding `brew "vault"` to Brewfile:
1. `vault --help` → has subcommands (read, write, list, login, etc.)
2. Add `"vault"` to `common_subcommands` under `# Cloud & Infra`
3. Commit both `brew/Brewfile` and `zsh/.config/atuin/config.toml` together

### Removing a tool

When removing a tool from Brewfile, also remove it from `common_subcommands`,
`ignored_commands`, or `common_prefix` in atuin config.toml.

## Sync Obligation: Brewfile → Zsh Completions

If a new CLI tool needs `bashcompinit`-style completions (like `tofu` or `mc`),
add the completion setup to `zsh/conf.d/90-completions.zsh`.

## Sync Obligation: Brewfile → _gnu_generic Fallback

If a new CLI tool has **no native zsh completion** (no `_<tool>` file in
Homebrew's `site-functions/`, zsh-completions, or any zimfw module), add it
to the tools list in `zsh/conf.d/80-gnu-generic.zsh`. This uses zsh's built-in
`_gnu_generic` to parse `--help` output for flag completion.

Check first: `ls /opt/homebrew/share/zsh/site-functions/_<tool>` — if it
exists, no action needed.
