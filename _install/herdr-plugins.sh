#!/usr/bin/env bash
#
# Reproducibly install the herdr plugins + agent integrations that the herdr
# config (herdr/.config/herdr/config.toml) references. Idempotent: already
# installed plugins are skipped. Run after `stow herdr` and after herdr itself
# is on PATH (brew).
#
# NOTE: plugins are third-party code pulled from GitHub and may run build steps
# on install (bun/npm). Review the repos before running on a new machine.

set -euo pipefail

echo -e "Install herdr plugins & integrations...."

if ! command -v herdr &>/dev/null; then
    echo -e "  ERROR: herdr not found on PATH — install it first (brew bundle)."
    exit 1
fi

# owner/repo slugs, keyed to the plugin_id the config binds to.
PLUGINS=(
    "lmilojevicc/herdr-splits.nvim"      # ctrl/alt+hjkl nav + resize (nvim-aware)
    "persiyanov/herdr-reviewr"           # cmd+r   code-review sidebar
    "Davidcreador/herdr-token-dashboard" # prefix+$ token spend dashboard
    "x0d7x/herdr-fzf-url"                # prefix+u URL picker
    "smarzban/herdr-file-viewer"         # cmd+o   git-aware file viewer
    "andrewchng/herdr-sessionizer"       # cmd+p   project/session + worktree picker
    "cloudmanic/herdr-plus"              # prefix+. quick actions + projects
    "wyattjoh/herdr-plugin-renamer"      # auto-rename workspaces from first prompt
    "hotchpotch/herdr-tiny-fingers"      # prefix+y tmux-fingers copy hints (needs cargo)
)

# Agent integrations herdr wires into detected panes.
INTEGRATIONS=(claude codex opencode)

installed="$(herdr plugin list 2>/dev/null || true)"

for repo in "${PLUGINS[@]}"; do
    if grep -q "github:${repo}" <<<"$installed"; then
        echo -e "  ✓ ${repo} (already installed)"
    else
        echo -e "  → installing ${repo}"
        herdr plugin install "$repo" --yes
    fi
done

for agent in "${INTEGRATIONS[@]}"; do
    echo -e "  → integration: ${agent}"
    herdr integration install "$agent" || echo -e "    (skipped — ${agent} integration unavailable)"
done

# Pick up newly registered plugin actions in the running server, if any.
herdr server reload-config &>/dev/null || true

echo -e "Done. Verify with: herdr plugin list && herdr plugin action list"
