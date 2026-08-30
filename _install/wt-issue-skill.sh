#!/usr/bin/env bash
#
# Register the wt-issue agent skill (GitLab issue → worktrunk worktree) for
# Claude Code and Codex.
#
# The skill content is versioned in this repo (_agents/skills/wt-issue) and
# linked into the shared-skill layout:
#   ~/.agents/skills/wt-issue    -> ~/.dotfiles/_agents/skills/wt-issue
#   ~/.claude/skills/wt-issue    -> ../../.agents/skills/wt-issue
#   ~/.codex/skills/wt-issue     -> ../../.agents/skills/wt-issue
#
# The engine itself is zsh/.local/bin/wt-issue (stowed → ~/.local/bin,
# reachable as `wt issue` via worktrunk's custom-subcommand mechanism).
#
# Usage: wt-issue-skill.sh   (idempotent — safe to re-run)

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
SKILL_SRC="$DOTFILES/_agents/skills/wt-issue"
if [[ ! -f "$SKILL_SRC/SKILL.md" ]]; then
    echo "  ERROR: wt-issue skill not found at $SKILL_SRC"
    exit 1
fi

SHARED="$HOME/.agents/skills"
mkdir -p "$SHARED"
ln -sfn "$SKILL_SRC" "$SHARED/wt-issue"
echo "  linked $SHARED/wt-issue -> $SKILL_SRC"

for agent_dir in "$HOME/.claude/skills" "$HOME/.codex/skills"; do
    mkdir -p "$agent_dir"
    ln -sfn "../../.agents/skills/wt-issue" "$agent_dir/wt-issue"
    echo "  linked $agent_dir/wt-issue -> ../../.agents/skills/wt-issue"
done

echo "Done. Agents can now start GitLab issues in worktrees (wt issue <N>)."
