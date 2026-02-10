# K9s Package — Agent Instructions

Rules for working on the K9s (Kubernetes TUI) configuration.

## Config Structure

```
k9s/
└── .config/k9s/
    ├── config.yaml        # Main config (UI, shell pod, thresholds, logging)
    ├── aliases.yaml       # Custom resource aliases (8 shortcuts)
    ├── plugins.yaml       # Custom plugin commands (15+ plugins)
    └── skins/
        ├── catppuccin-mocha.yaml              # Opaque theme
        └── catppuccin-mocha-transparent.yaml  # Active theme (transparent bg)
```

## Theme

Uses `catppuccin-mocha-transparent` (set in `config.yaml` → `ui.skin`).
Always prefer the transparent variant for consistent terminal integration.

## Custom Aliases

Short aliases for common Kubernetes resources (e.g. `dp` → deployments,
`sec` → secrets). Keep these minimal — k9s has built-in aliases for most
resources.

## Plugins

Plugins are defined in `plugins.yaml`. Each plugin has:

- `shortCut` — key binding (e.g. `Shift-B` for blame)
- `scopes` — resource types the plugin applies to
- `command` / `args` — the actual command to run
- `dangerous` — set to `true` for destructive operations

Plugins use k9s environment variables for context:
`$CONTEXT`, `$NAMESPACE`, `$NAME`, `$RESOURCE_NAME`, `$COL-<header>`

### External Tool Dependencies

Many plugins require tools from `brew/Brewfile`:

| Plugin        | Requires           |
|---------------|-------------------|
| blame         | kubectl-blame      |
| debug         | kubectl            |
| dive          | dive               |
| stern         | stern              |
| helm-values   | helm               |
| krr           | krr                |
| cert-*        | cmctl              |
| holmesgpt     | holmes             |
| crd-wizard*   | kubectl-crd_wizard (krew) |

Verify tools are installed before adding plugins that depend on them.

## Resource Thresholds

CPU/Memory warnings at 70%, critical at 90%. These are sensible defaults —
only change if cluster workloads justify different thresholds.

## Shell Pod

Uses `busybox:1.35.0` with 100m CPU / 100Mi memory limits. When updating
the image tag, keep it lightweight.
