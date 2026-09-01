---
name: wt-issue
description: Start work on a GitLab issue in its own git worktree, and publish it as a draft merge request. Use when the user references a GitLab issue to implement or fix (e.g. "arbeite an Issue 142", "fix #142", "nimm Ticket 142") inside a repo with a GitLab remote, or when work on such a branch needs to reach the remote. Creates the <N>-<slug> branch + worktree via worktrunk, moves the work there, and pushes through `wt publish`.
---

# GitLab issue → worktree → merge request

Two commands, both worktrunk custom subcommands (scripts stowed at
`~/.local/bin/`): `wt issue` starts the ticket, `wt publish` puts it on the
remote. Worktrees land in the central `~/Projects/_worktrees/<repo-dir>/<branch>`
layout; branch names follow GitLab's `%{id}-%{title}` pattern so MRs auto-link
the issue.

Everything on a worktree goes through `wt` — never `git worktree`, and in MR
mode never a raw `git push`.

## MR mode

`wt issue` decides once per branch whether this ticket gets a draft merge
request, and stores the answer at `branch.<branch>.wtIssueMr`. Precedence:

1. **`--mr` / `--no-mr`** on either command — wins over everything, last flag
   wins, and the new value is stored.
2. **The stored decision** — every later call follows it. A `.gitlab-ci.yml`
   edited in the meantime never silently flips a branch that already decided.
3. **The repo heuristic** — on only when a remote exists *and* `.gitlab-ci.yml`
   mentions `merge_request_event`, i.e. exactly the repos where no MR means no
   pipeline runs at all.

Nobody is ever prompted. The chosen mode is printed to stderr on every run.

## Claude Code — move this session into the worktree

1. Derive the branch: `wt issue <N> --branch-only` (fetches the title via
   glab, prints `<N>-<slug>`; needs no worktree yet). This also settles MR
   mode — the branch name is on stdout, the mode on stderr.
2. Call the `EnterWorktree` tool with `{"name": "<branch>"}` — the worktrunk
   plugin creates the worktree via `wt switch --create` and re-roots the
   session into it.
3. Load context: `glab issue view <N>` and `glab issue view <N> --comments`.
4. **Brainstorm before building**: run an alignment round with the user
   (use the `superpowers:brainstorming` skill if available) — summarize
   your understanding, ask what has changed since the issue was written,
   clarify open questions and acceptance criteria. Start implementing only
   after the user confirms the direction.
5. Publish with `wt publish` (see below). Never `git push` on a branch in MR
   mode: the merge request is created *by* the push options, so a raw push
   silently produces a branch without an MR.

## Codex / agents without EnterWorktree

1. `wt issue <N> --no-agent` creates the worktree (prints the path via wt).
2. Continue with that path as cwd (`-C <path>` / cd), then steps 3–5 above.

## Humans (shell)

- `wt issue 142` — worktree + Claude Code opens inside it with the issue as
  its first prompt.
- `wt issue 142 --agent codex` — same with Codex.
- `wt issue 142 --no-agent` — worktree only; the shell cds there.
- `wt issue 142 --no-mr` — start it without a merge request after all.

## Publishing

`wt publish` pushes the current branch and, in MR mode, opens the draft MR in
the same round-trip via GitLab's merge-request push options: draft, target =
the remote's default branch, source branch removed on merge, title
`Resolve "<issue title>"`, description `Closes #<N>` taken from the branch
name. A merge request that is already open is detected and left alone.

- `wt publish` — push, opening the draft MR if MR mode says so
- `wt publish --no-mr` — push this branch bare, and remember that
- `wt publish --dry-run` — print the git command instead of running it

worktrunk itself has no remote push: `wt step push` fast-forwards a *local*
branch ("no commits leave the repository", per its own help). `wt publish` is
the one step that talks to the forge.

## Finishing

The two modes end differently, and mixing them loses the review:

- **MR mode on** — merge in GitLab once the pipeline is green. Do **not** run
  `wt merge`; it squashes into the target branch locally and fast-forwards it,
  which bypasses the merge request entirely. Clean up with `wt remove <branch>`
  after the MR merged.
- **MR mode off** — the usual worktrunk flow: `wt merge`, which also removes
  the worktree.

Labels, reviewers and milestones are not touched by either command. If the
project ships a workflow skill, follow it for those.

## Requirements

`glab` authenticated for the repo's GitLab host (self-hosted: set
`GITLAB_HOST` or rely on the remote), `jq`, `worktrunk`. `wt publish` degrades
without glab: it still creates the MR and still writes `Closes #<N>` (the issue
number comes from the branch name) — only the title needs the issue lookup.
