#!/usr/bin/env bash
#
# Register Hunk's bundled hunk-review agent skill for Claude Code and Codex.
#
# Hunk ships the skill inside its Homebrew keg and regenerates it on every
# upgrade, so we link through the version-stable opt path (brew --prefix)
# instead of copying: content stays current, links never go stale.
#
# Layout follows the existing shared-skill convention:
#   ~/.agents/skills/hunk-review    -> <brew>/opt/hunk/libexec/skills/hunk-review
#   ~/.claude/skills/hunk-review    -> ../../.agents/skills/hunk-review
#   ~/.codex/skills/hunk-review     -> ../../.agents/skills/hunk-review
#
# Usage: hunk-skill.sh   (idempotent — safe to re-run)

set -euo pipefail

if ! command -v brew &>/dev/null; then
    echo "  ERROR: brew not found on PATH — install Homebrew first."
    exit 1
fi

SKILL_SRC="$(brew --prefix)/opt/hunk/libexec/skills/hunk-review"
if [[ ! -f "$SKILL_SRC/SKILL.md" ]]; then
    echo "  ERROR: hunk-review skill not found at $SKILL_SRC — install hunk first (brew bundle)."
    exit 1
fi

SHARED="$HOME/.agents/skills"
mkdir -p "$SHARED"
ln -sfn "$SKILL_SRC" "$SHARED/hunk-review"
echo "  linked $SHARED/hunk-review -> $SKILL_SRC"

for agent_dir in "$HOME/.claude/skills" "$HOME/.codex/skills"; do
    mkdir -p "$agent_dir"
    ln -sfn "../../.agents/skills/hunk-review" "$agent_dir/hunk-review"
    echo "  linked $agent_dir/hunk-review -> ../../.agents/skills/hunk-review"
done

echo "Done. Agents can now drive live Hunk sessions (hunk session *)."
