#!/usr/bin/env bash
#
# Wire T3 Code (pingdotgg/t3code) to both Claude subscriptions and Codex.
#
# T3 runs one "provider instance" per account. Each Claude instance gets its
# own CLAUDE_CONFIG_DIR (T3's `homePath`), so it has its own login and
# Keychain item — Claude Code namespaces the item per config dir. To make
# skills, plugins, hooks, agents, CLAUDE.md and transcripts identical to the
# CLI, every config dir is a symlink forest into ~/.claude, the same layout
# `clauth start` uses for its runtime dirs:
#
#   ~/.claude-t3/<profile>/<entry>  -> ~/.claude/<entry>   (everything shared)
#   ~/.claude-t3/<profile>/.claude.json                    (per-account copy)
#
# Never linked: credentials and the caches Claude Code fills per account or
# organization. .claude.json is a copy because it embeds the signed-in
# account (`oauthAccount`); only its mcpServers block is kept in sync with
# ~/.claude.json.
#
# The overlay t3/settings.json is deep-merged into ~/.t3/userdata/settings.json
# (overlay wins, everything else T3 stores there is kept). T3 watches that file
# and reloads it live. The live file is never stowed: it sits next to SQLite
# databases, secrets and logs, see t3/AGENTS.md.
#
# Usage: t3.sh   (idempotent — safe to re-run; `update skills` re-runs it)

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
CLAUDE_HOME="$HOME/.claude"
T3_CLAUDE_ROOT="$HOME/.claude-t3"
T3_USERDATA="$HOME/.t3/userdata"
OVERLAY="$DOTFILES/t3/settings.json"

# Must match the homePath values in t3/settings.json. Named like the clauth
# profiles, but independent of them: T3 never goes through clauth.
PROFILES=(private work)

# Per-account state: credentials plus the org policy, managed settings and
# MCP auth caches Claude Code writes for whichever account is signed in.
PER_ACCOUNT=(.credentials.json .claude.json policy-limits.json remote-settings.json mcp-needs-auth-cache.json)

if ! command -v jq &>/dev/null; then
    echo "  ERROR: jq not found on PATH — run 'brew bundle' first."
    exit 1
fi
if [[ ! -d "$CLAUDE_HOME" ]]; then
    echo "  ERROR: $CLAUDE_HOME not found — set up Claude Code first."
    exit 1
fi

is_per_account() {
    local name="$1" entry
    for entry in "${PER_ACCOUNT[@]}"; do
        [[ "$name" == "$entry" ]] && return 0
    done
    return 1
}

# Write stdin to $1 via a temp file + rename, owner-only, only when changed.
write_if_changed() {
    local dst="$1" tmp
    tmp="$(mktemp "${dst}.XXXXXX")"
    cat > "$tmp"
    chmod 600 "$tmp"
    if [[ -f "$dst" ]] && cmp -s "$tmp" "$dst"; then
        rm -f "$tmp"
        return 1
    fi
    mv -f "$tmp" "$dst"
}

build_forest() {
    local dir="$1" src name dst linked=0
    mkdir -p "$dir"
    chmod 700 "$dir"

    # Drop links whose ~/.claude target is gone (renamed or deleted entry).
    for dst in "$dir"/* "$dir"/.[!.]*; do
        [[ -L "$dst" && ! -e "$dst" ]] && rm -f "$dst"
    done

    for src in "$CLAUDE_HOME"/* "$CLAUDE_HOME"/.[!.]*; do
        [[ -e "$src" || -L "$src" ]] || continue
        name="$(basename "$src")"
        is_per_account "$name" && continue
        # Atomic-write leftovers (settings.json.tmp.<pid>…) are not content.
        [[ "$name" == *.tmp.* ]] && continue
        dst="$dir/$name"
        if [[ -L "$dst" ]]; then
            continue
        fi
        if [[ -e "$dst" ]]; then
            # Claude Code rewrites settings.json atomically, which replaces the
            # link with a regular file. Keep a diverged copy, then relink.
            if [[ -f "$dst" ]] && ! cmp -s "$dst" "$src"; then
                mv "$dst" "$dst.t3-$(date +%Y%m%d-%H%M%S)"
                echo "  note: $dst had diverged — kept as backup, relinked"
            else
                rm -rf "${dst:?}"
            fi
        fi
        ln -s "$src" "$dst"
        linked=$((linked + 1))
    done
    echo "  $(basename "$dir"): $linked new link(s)"
}

# Seed the per-account .claude.json once (minus the global account identity),
# then keep only its mcpServers block in sync with ~/.claude.json.
sync_claude_json() {
    local dir="$1" global="$HOME/.claude.json" dst="$1/.claude.json"
    [[ -f "$global" ]] || return 0
    if [[ ! -f "$dst" ]]; then
        jq 'del(.oauthAccount)' "$global" | write_if_changed "$dst" || true
        echo "  $(basename "$dir"): .claude.json seeded from ~/.claude.json"
        return
    fi
    if jq --slurpfile g "$global" '.mcpServers = ($g[0].mcpServers // {})' "$dst" \
        | write_if_changed "$dst"; then
        echo "  $(basename "$dir"): MCP servers synced"
    fi
}

merge_overlay() {
    local live="$T3_USERDATA/settings.json"
    mkdir -p "$T3_USERDATA"
    if [[ ! -f "$live" ]]; then
        jq . "$OVERLAY" | write_if_changed "$live" || true
        echo "  T3 settings created from overlay"
        return
    fi
    if jq -s '.[0] * .[1]' "$live" "$OVERLAY" | write_if_changed "$live"; then
        echo "  T3 settings updated from overlay (T3 reloads it live)"
    else
        echo "  T3 settings already up to date"
    fi
}

echo "  → Claude config dirs for T3 (symlink forests into ~/.claude)"
for profile in "${PROFILES[@]}"; do
    build_forest "$T3_CLAUDE_ROOT/$profile"
    sync_claude_json "$T3_CLAUDE_ROOT/$profile"
done

echo "  → T3 settings overlay"
merge_overlay

# Report logins; never start one — that is an interactive browser flow.
missing=()
if command -v claude &>/dev/null; then
    for profile in "${PROFILES[@]}"; do
        if ! CLAUDE_CONFIG_DIR="$T3_CLAUDE_ROOT/$profile" claude auth status --json 2>/dev/null \
            | jq -e '.loggedIn == true' >/dev/null; then
            missing+=("$profile")
        fi
    done
fi
if (( ${#missing[@]} )); then
    echo "  Not signed in yet — run once per account, with the matching subscription:"
    for profile in "${missing[@]}"; do
        echo "    CLAUDE_CONFIG_DIR=~/.claude-t3/$profile claude auth login"
    done
fi

echo "Done. Restart running T3 agent sessions to pick up new skills or plugins."
