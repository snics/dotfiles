#!/usr/bin/env bash
#
# Bootstrap herdr plugin management via herdr-lazy (natori-hrj/herdr-lazy).
# The declarative plugin set lives in herdr/.config/herdr/plugins.list and the
# resolved commits in plugins.lock next to it (both stowed + versioned;
# HERDR_LAZY_LIST in zsh/.zprofile points herdr-lazy at them).
#
# Usage:
#   herdr-plugins.sh            install herdr-lazy if missing, then sync --prune
#   herdr-plugins.sh --restore  converge to the exact commits in plugins.lock
#   herdr-plugins.sh --update   additionally update all unpinned plugins
#
# NOTE: plugins are third-party code pulled from GitHub and may run build steps
# on install. Review the repos (and plugins.list) before running on a new machine.

set -euo pipefail

MODE="sync"
case "${1:-}" in
    --update) MODE="update" ;;
    --restore) MODE="restore" ;;
esac

if ! command -v herdr &>/dev/null; then
    echo "  ERROR: herdr not found on PATH — install it first (brew bundle)."
    exit 1
fi

export HERDR_LAZY_LIST="${HERDR_LAZY_LIST:-$HOME/.dotfiles/herdr/.config/herdr/plugins.list}"

# Bootstrap the plugin manager itself (the only imperative install left).
if ! herdr plugin list 2>/dev/null | grep -q "github:natori-hrj/herdr-lazy"; then
    echo "  → installing herdr-lazy (plugin manager)"
    herdr plugin install natori-hrj/herdr-lazy --yes
fi

# Resolve the herdr-lazy binary inside herdr's hashed plugin directory.
lazy_root="$(herdr plugin list --json | python3 -c \
    "import json,sys;print([p['plugin_root'] for p in json.load(sys.stdin)['result']['plugins'] if p['plugin_id']=='herdr-lazy'][0])")"
lazy="$lazy_root/target/release/herdr-lazy"

case "$MODE" in
    restore)
        echo "  → herdr-lazy restore (exact commits from plugins.lock)"
        "$lazy" restore
        ;;
    *)
        echo "  → herdr-lazy sync --prune (converge to plugins.list)"
        "$lazy" sync --prune
        if [[ "$MODE" == "update" ]]; then
            echo "  → herdr-lazy update (all unpinned plugins)"
            "$lazy" update
        fi
        ;;
esac

# Agent integrations herdr wires into detected panes (idempotent).
for agent in claude codex; do
    echo "  → integration: ${agent}"
    herdr integration install "$agent" || echo "    (skipped — ${agent} integration unavailable)"
done

# Pick up newly registered plugin actions in the running server, if any.
herdr server reload-config &>/dev/null || true

echo "Done. Verify with: herdr plugin list && $lazy check"
