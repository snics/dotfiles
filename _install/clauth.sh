#!/usr/bin/env bash
#
# Register clauth's herdr plugin WITHOUT letting it touch herdr's config.
#
# `clauth herdr install` would append its keybinding and sidebar block to
# herdr's config.toml — which is a stow symlink here, so the write would land
# in the repository as an unreviewed change. `--no-config` installs the plugin
# and returns before resolving or writing that file; the equivalent blocks are
# hand-authored in herdr/.config/herdr/config.toml instead.
#
# Consequence: `--no-config` also skips clauth's own keybinding conflict check,
# so the hand-authored key must be verified by hand. It is `prefix+d`, because
# clauth's default `prefix+a` is already bound to `next_agent` here.
#
# See docs/superpowers/specs/2026-08-30-clauth-integration-design.md.
#
# Usage: clauth.sh

set -euo pipefail

if ! command -v clauth &>/dev/null; then
    echo "  ERROR: clauth not found on PATH — run 'just cargo-tools' first."
    exit 1
fi

if ! command -v herdr &>/dev/null; then
    echo "  ERROR: herdr not found on PATH — install it first (brew bundle)."
    exit 1
fi

echo "  → registering the clauth herdr plugin (config left untouched)"
clauth herdr install --no-config -y

# profiles.toml is intentionally NOT symlinked: clauth rewrites it in place
# (profile ordering, the active marker), which destroys a stow symlink and
# leaves the repo copy stale. Bootstrap-copy the template if none exists;
# afterwards sync the live file back with `just clauth-sync`.
PROFILES_SRC="$(dirname "${BASH_SOURCE[0]}")/../clauth/.clauth/profiles.toml"
PROFILES_DST="$HOME/.clauth/profiles.toml"
mkdir -p "$HOME/.clauth"
if [ ! -e "$PROFILES_DST" ]; then
    cp "$PROFILES_SRC" "$PROFILES_DST"
    echo "  profiles.toml copied to ~/.clauth/"
else
    echo "  profiles.toml already exists — left untouched (use 'just clauth-sync' to update the repo)"
fi

echo "Done. Verify with: herdr plugin list | grep clauth"
echo "Reminder: never run 'clauth herdr install' without --no-config."
