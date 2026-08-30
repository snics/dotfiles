---
name: wt-issue
description: Start work on a GitLab issue in its own git worktree. Use when the user references a GitLab issue to implement or fix (e.g. "arbeite an Issue 142", "fix #142", "nimm Ticket 142") inside a repo with a GitLab remote. Creates the <N>-<slug> branch + worktree via worktrunk and moves the work there.
---

# GitLab issue → worktree (`wt issue`)

One engine for humans and every agent: the `wt issue` command (worktrunk
custom subcommand; script stowed at `~/.local/bin/wt-issue`). Worktrees land
in the central `~/Projects/_worktrees/<repo-dir>/<branch>` layout; branch names
follow GitLab's `%{id}-%{title}` pattern so MRs auto-link the issue.

## Claude Code — move this session into the worktree

1. Derive the branch: `wt issue <N> --branch-only` (fetches the title via
   glab, prints `<N>-<slug>`; needs no worktree yet).
2. Call the `EnterWorktree` tool with `{"name": "<branch>"}` — the worktrunk
   plugin creates the worktree via `wt switch --create` and re-roots the
   session into it.
3. Load context: `glab issue view <N>` and `glab issue view <N> --comments`.
4. **Brainstorm before building**: run an alignment round with the user
   (use the `superpowers:brainstorming` skill if available) — summarize
   your understanding, ask what has changed since the issue was written,
   clarify open questions and acceptance criteria. Start implementing only
   after the user confirms the direction.
5. If the project has a workflow skill (e.g. `gitlab-workflow`), follow it
   for labels, draft MR, and `Refs #<N>` — this engine never touches those.

## Codex / agents without EnterWorktree

1. `wt issue <N> --no-agent` creates the worktree (prints the path via wt).
2. Continue with that path as cwd (`-C <path>` / cd), then steps 3–5 above.

## Humans (shell)

- `wt issue 142` — worktree + Claude Code opens inside it with the issue as
  its first prompt.
- `wt issue 142 --agent codex` — same with Codex.
- `wt issue 142 --no-agent` — worktree only; the shell cds there.

## Requirements

`glab` authenticated for the repo's GitLab host (self-hosted: set
`GITLAB_HOST` or rely on the remote), `jq`, `worktrunk`.
