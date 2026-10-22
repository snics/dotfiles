#!/usr/bin/env bash
#
# Mirror the Claude Code marketing plugins (claude-ads, claude-seo) into Codex.
#
# Both plugins are installed in Claude Code from their marketplaces, whose git
# clones live at stable paths under ~/.claude/plugins/marketplaces/. Codex has
# no plugin of its own for them, so:
#
#   claude-ads — the upstream installer supports Codex (--target=codex). It
#                copies skills + agents into ~/.codex/{skills,agents} and
#                builds a verified Python venv. Re-run to update.
#   claude-seo — upstream dropped its Codex port (2026-10-19), and its manual
#                installer is hard-wired to ~/.claude. We bridge instead:
#                ~/.codex/skills/<seo-skill> -> <marketplace clone>/skills/<seo-skill>
#                and set the plugin variables the skills expect only in Codex's
#                shell environment (config.toml [shell_environment_policy]).
#                Skill content follows the marketplace clone automatically;
#                re-run to pick up added/removed skills or rebuild the venv.
#
# Codex gets its own SEO runtime dir so it never rebuilds Claude Code's venv.
# Both upstream runtimes support Python 3.11/3.12 only, so we pin 3.12.
#
# Usage: codex-marketing-skills.sh   (idempotent — safe to re-run)

set -euo pipefail

MARKETPLACES="$HOME/.claude/plugins/marketplaces"
ADS_SRC="$MARKETPLACES/ai-marketing-hub-claude-ads"
SEO_SRC="$MARKETPLACES/agricidaniel-claude-seo"
SEO_DATA="$HOME/.local/share/claude-seo-codex"
CODEX_SKILLS="$HOME/.codex/skills"
CODEX_CONFIG="$HOME/.codex/config.toml"

PYTHON312="$(brew --prefix 2>/dev/null)/bin/python3.12"
if [[ ! -x "$PYTHON312" ]]; then
    echo "  ERROR: python3.12 not found at $PYTHON312 — brew install python@3.12"
    exit 1
fi
for src in "$ADS_SRC" "$SEO_SRC"; do
    if [[ ! -d "$src" ]]; then
        echo "  ERROR: marketplace clone missing: $src — install the Claude plugin first"
        exit 1
    fi
done

# --- claude-ads: upstream installer ------------------------------------------
# The installer resolves `python3`; shadow it with 3.12 for this run only.
shim="$(mktemp -d)"
trap 'rm -rf "$shim"' EXIT
ln -s "$PYTHON312" "$shim/python3"
PATH="$shim:$PATH" bash "$ADS_SRC/install.sh" --target=codex --repo-dir="$ADS_SRC" >/dev/null
echo "  claude-ads installed for Codex"

# --- claude-seo: bridge ------------------------------------------------------
mkdir -p "$CODEX_SKILLS"
# Drop bridge links whose upstream skill no longer exists.
for link in "$CODEX_SKILLS"/seo "$CODEX_SKILLS"/seo-*; do
    [[ -L "$link" && ! -e "$link" ]] && rm "$link"
done
count=0
for dir in "$SEO_SRC"/skills/*/; do
    skill="$(basename "$dir")"
    [[ "$skill" == seo || "$skill" == seo-* ]] || continue
    target="$CODEX_SKILLS/$skill"
    if [[ -e "$target" && ! -L "$target" ]]; then
        echo "  ERROR: $target is a real folder, not a bridge link — remove it first"
        exit 1
    fi
    ln -sfn "${dir%/}" "$target"
    count=$((count + 1))
done
echo "  claude-seo bridged: $count skills"

if ! grep -q '^\[shell_environment_policy\]' "$CODEX_CONFIG"; then
    cat >> "$CODEX_CONFIG" <<EOF

# claude-seo bridge (managed by ~/.dotfiles/_install/codex-marketing-skills.sh)
[shell_environment_policy]
set = { CLAUDE_PLUGIN_ROOT = "$SEO_SRC", CLAUDE_SEO_DATA_DIR = "$SEO_DATA", CLAUDE_SEO_PYTHON = "$PYTHON312" }
EOF
    echo "  added [shell_environment_policy] to $CODEX_CONFIG"
elif ! grep -q 'CLAUDE_SEO_DATA_DIR' "$CODEX_CONFIG"; then
    echo "  WARNING: $CODEX_CONFIG already has [shell_environment_policy];"
    echo "           add CLAUDE_PLUGIN_ROOT, CLAUDE_SEO_DATA_DIR and CLAUDE_SEO_PYTHON to its 'set' by hand."
fi

mkdir -p "$SEO_DATA"
CLAUDE_PLUGIN_ROOT="$SEO_SRC" CLAUDE_SEO_DATA_DIR="$SEO_DATA" CLAUDE_SEO_PYTHON="$PYTHON312" \
    "$SEO_SRC/scripts/claude-seo" setup >/dev/null
echo "  claude-seo runtime ready in $SEO_DATA"

echo "Done. Restart Codex to load the skills."
