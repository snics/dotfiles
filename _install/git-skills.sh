#!/usr/bin/env bash
#
# Register the self-written git agent skills (secret audits, Gitmoji commits)
# for every local coding agent.
#
# The skill content is versioned in this repo (_agents/skills/<skill>) and
# linked into the shared-skill layout:
#   ~/.agents/skills/<skill>    -> ~/.dotfiles/_agents/skills/<skill>
#   ~/.claude/skills/<skill>    -> ../../.agents/skills/<skill>
#
# Codex, Cursor and Pi read ~/.agents/skills directly; only Claude
# Code needs its own link.
#
# Usage: git-skills.sh   (idempotent — safe to re-run)

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
SKILLS=(git-guardian-pre-push-history git-guardian-workspace gitmoji-commit-expert-strict)

SHARED="$HOME/.agents/skills"
mkdir -p "$SHARED" "$HOME/.claude/skills"

for skill in "${SKILLS[@]}"; do
    src="$DOTFILES/_agents/skills/$skill"
    if [[ ! -f "$src/SKILL.md" ]]; then
        echo "  ERROR: $skill not found at $src"
        exit 1
    fi
    # Replace a former hand-copied folder; never follow it into the repo.
    if [[ -d "$SHARED/$skill" && ! -L "$SHARED/$skill" ]]; then
        rm -rf "${SHARED:?}/$skill"
    fi
    ln -sfn "$src" "$SHARED/$skill"
    ln -sfn "../../.agents/skills/$skill" "$HOME/.claude/skills/$skill"
    echo "  linked $skill"
done

echo "Done. ${#SKILLS[@]} git skills available to all agents."
