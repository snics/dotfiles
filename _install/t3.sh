#!/usr/bin/env bash
#
# Wire T3 Code (pingdotgg/t3code) to both Claude subscriptions and Codex.
#
# T3 runs one "provider instance" per account. Each Claude instance gets its
# own CLAUDE_CONFIG_DIR (T3's `homePath`), so it has its own login and
# Keychain item — Claude Code namespaces the item per config dir. The dirs
# live in T3's own per-instance namespace, the layout T3 uses for managed
# Codex shadow homes (providers/<driver>/<instanceId>/<role>):
#
#   ~/.t3/userdata/providers/claudeAgent/<instanceId>/home/
#     <shared entry>  -> ~/.claude/<shared entry>   (config only, see SHARED)
#     .claude.json                                   (per-account, seeded once)
#     everything else                                (per-account, Claude-owned)
#
# Only configuration is shared. Transcripts, history and caches stay per
# account: a shared projects/ makes T3 import one session under both
# instances, and the policy/billing caches belong to whichever account wrote
# them.
#
# The overlays in t3/ are deep-merged into T3's live files (overlay wins,
# everything else T3 stored is kept):
#   t3/settings.json        -> ~/.t3/userdata/settings.json         (live reload)
#   t3/client-settings.json -> ~/.t3/userdata/client-settings.json  (only while
#                              T3 is closed: the app reads it once and rewrites
#                              the whole file on every UI change)
#
# Usage: t3.sh   (idempotent — safe to re-run; `update skills` re-runs it)

# jq filters below use jq variables ($k, $g), not shell ones.
# shellcheck disable=SC2016
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
CLAUDE_HOME="$HOME/.claude"
T3_USERDATA="$HOME/.t3/userdata"
CLAUDE_INSTANCES_ROOT="$T3_USERDATA/providers/claudeAgent"
LEGACY_ROOT="$HOME/.claude-t3"

# T3 instance ids, must match `homePath` in t3/settings.json.
# claudeAgent = private subscription, claudeWork = work subscription.
INSTANCES=(claudeAgent claudeWork)

# Environment theme, a file in t3/themes/ (Catppuccin Mocha, like Ghostty).
DEFAULT_THEME="catppuccin-mocha"

# Top-level ~/.claude entries shared with every instance: configuration only.
SHARED=(CLAUDE.md agents commands hooks keybindings.json output-styles plugins
    settings.json settings.local.json skills)

# ~/.claude.json keys copied into a new per-account .claude.json. An allowlist
# on purpose: the file also carries the signed-in identity, API-key approvals
# and account/org model and billing caches, none of which may cross accounts.
SEED_KEYS='["mcpServers","theme","editorMode","hasCompletedOnboarding","lastOnboardingVersion","preferredNotifChannel","autoCompactEnabled","verbose"]'

if ! command -v jq &>/dev/null; then
    echo "  ERROR: jq not found on PATH — run 'brew bundle' first."
    exit 1
fi
if [[ ! -d "$CLAUDE_HOME" ]]; then
    echo "  ERROR: $CLAUDE_HOME not found — set up Claude Code first."
    exit 1
fi

# Run `jq "$@"` and atomically replace $dst with the result — only when jq
# succeeded, produced a JSON object, and the content changed. Returns 0 when
# the file was written, 1 when unchanged; exits on any jq failure, leaving
# $dst untouched.
jq_replace() {
    local dst="$1" tmp
    shift
    tmp="$(mktemp "${dst}.XXXXXX")"
    if ! jq "$@" > "$tmp" || ! jq -e 'type == "object"' "$tmp" >/dev/null; then
        rm -f "$tmp"
        echo "  ERROR: could not build $dst — left unchanged"
        exit 1
    fi
    if [[ -f "$dst" ]] && cmp -s "$tmp" "$dst"; then
        rm -f "$tmp"
        return 1
    fi
    chmod 600 "$tmp"
    mv -f "$tmp" "$dst"
}

logged_in() {
    command -v claude &>/dev/null || return 1
    CLAUDE_CONFIG_DIR="$1" claude auth status --json 2>/dev/null \
        | jq -e '.loggedIn == true' >/dev/null
}

build_home() {
    local dir="$1" name src dst linked=0
    mkdir -p "$dir"
    chmod 700 "$dir" "$(dirname "$dir")"

    for name in "${SHARED[@]}"; do
        src="$CLAUDE_HOME/$name"
        dst="$dir/$name"
        if [[ ! -e "$src" ]]; then
            # Entry gone from ~/.claude: drop our link, never anything else.
            [[ -L "$dst" ]] && rm -f "$dst"
            continue
        fi
        [[ -L "$dst" ]] && continue
        if [[ -d "$dst" ]]; then
            echo "  WARN: $dst is a real directory — left alone, not linked"
            continue
        fi
        if [[ -f "$dst" ]]; then
            # Claude Code rewrites settings.json atomically, which replaces
            # the link with a regular file. Keep a diverged copy, then relink.
            if cmp -s "$dst" "$src"; then
                rm -f "$dst"
            else
                mv "$dst" "$dst.t3-$(date +%Y%m%d-%H%M%S)"
                echo "  note: $dst had diverged — kept as backup, relinked"
            fi
        fi
        ln -s "$src" "$dst"
        linked=$((linked + 1))
    done
    echo "  $(basename "$(dirname "$dir")"): $linked new link(s)"
}

# Seed the per-account .claude.json once from an allowlist, then keep only its
# mcpServers block in sync with ~/.claude.json.
sync_claude_json() {
    local dir="$1" global="$HOME/.claude.json" dst="$1/.claude.json"
    local label
    label="$(basename "$(dirname "$dir")")"
    [[ -f "$global" ]] || return 0
    if [[ ! -f "$dst" ]]; then
        jq_replace "$dst" --argjson keys "$SEED_KEYS" \
            'with_entries(select(.key as $k | $keys | index($k)))' "$global" || true
        echo "  $label: .claude.json seeded (allowlisted keys only)"
        return
    fi
    # Compare semantically: Claude Code reformats the file on every start,
    # so a byte compare would rewrite it (and race Claude) on every run.
    if [[ "$(jq -cS '.mcpServers // {}' "$global")" == "$(jq -cS '.mcpServers // {}' "$dst")" ]]; then
        return 0
    fi
    if jq_replace "$dst" --slurpfile g "$global" \
        '.mcpServers = ($g[0].mcpServers // {})' "$dst"; then
        echo "  $label: MCP servers synced"
    fi
}

# v1 kept the homes in ~/.claude-t3/<profile>. Remove them only while they
# hold nothing but what this script put there and nobody is signed in.
remove_legacy() {
    local dir entry
    [[ -d "$LEGACY_ROOT" ]] || return 0
    for dir in "$LEGACY_ROOT"/*/; do
        dir="${dir%/}"
        [[ -d "$dir" ]] || continue
        if logged_in "$dir"; then
            echo "  WARN: $dir is signed in — kept. Log out there first:"
            echo "        CLAUDE_CONFIG_DIR=$dir claude auth logout"
            continue
        fi
        for entry in "$dir"/* "$dir"/.[!.]*; do
            [[ -L "$entry" ]] && rm -f "$entry"
        done
        rm -f "$dir/.claude.json"
        if rmdir "$dir" 2>/dev/null; then
            echo "  removed legacy $dir"
        else
            echo "  WARN: $dir still has files Claude created — kept for review"
        fi
    done
    rmdir "$LEGACY_ROOT" 2>/dev/null || true
}

merge_overlay() {
    local name="$1" live="$T3_USERDATA/$1" overlay="$DOTFILES/t3/$1"
    if [[ ! -f "$live" ]]; then
        jq_replace "$live" . "$overlay" || true
        echo "  $name created from overlay"
    elif jq_replace "$live" -s '.[0] * .[1]' "$live" "$overlay"; then
        echo "  $name updated from overlay"
    else
        echo "  $name already up to date"
    fi
}

# Publish t3/themes/*.json into T3's themes dir (filename = theme id) and make
# DEFAULT_THEME the environment theme — what `t3 theme set <id>` does, without
# needing the CLI on PATH. The default is written only when it changes: every
# new defaultThemeSetAt makes clients re-apply it, which would undo a theme
# picked in Settings on each run.
publish_themes() {
    local src dst tmp
    mkdir -p "$T3_USERDATA/themes"
    for src in "$DOTFILES"/t3/themes/*.json; do
        dst="$T3_USERDATA/themes/$(basename "$src")"
        if cmp -s "$src" "$dst"; then
            continue
        fi
        tmp="$(mktemp "${dst}.XXXXXX")"
        cp "$src" "$tmp"
        mv -f "$tmp" "$dst"
        echo "  published theme $(basename "$src" .json)"
    done
    if [[ "$(jq -r '.defaultTheme // ""' "$T3_USERDATA/settings.json")" != "$DEFAULT_THEME" ]]; then
        jq_replace "$T3_USERDATA/settings.json" --arg t "$DEFAULT_THEME" \
            --arg at "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)" \
            '.defaultTheme = $t | .defaultThemeSetAt = $at' "$T3_USERDATA/settings.json" || true
        echo "  environment theme set to $DEFAULT_THEME"
    fi
}

echo "  → Claude homes for T3 (config shared from ~/.claude)"
for instance in "${INSTANCES[@]}"; do
    home="$CLAUDE_INSTANCES_ROOT/$instance/home"
    build_home "$home"
    sync_claude_json "$home"
done
remove_legacy

echo "  → T3 settings overlays"
mkdir -p "$T3_USERDATA"
merge_overlay settings.json
if pgrep -qf '/T3 Code.*\.app/Contents/MacOS/'; then
    echo "  client-settings.json skipped — T3 is running (quit T3 and re-run 'just t3')"
else
    merge_overlay client-settings.json
fi

echo "  → T3 themes"
publish_themes
# Report logins; never start one — that is an interactive browser flow.
missing=()
for instance in "${INSTANCES[@]}"; do
    logged_in "$CLAUDE_INSTANCES_ROOT/$instance/home" || missing+=("$instance")
done
if (( ${#missing[@]} )); then
    echo "  Not signed in yet — run once per instance, with the matching subscription"
    echo "  (claudeAgent = private, claudeWork = work):"
    for instance in "${missing[@]}"; do
        echo "    CLAUDE_CONFIG_DIR=~/.t3/userdata/providers/claudeAgent/$instance/home claude auth login"
    done
fi

echo "Done. In T3, use 'Restart agent session' to pick up changes in running threads."
