# Skills CLI Integration

> Manage Agent Skills for Cursor, Claude Code and other AI tools in the dotfiles

## Goal

Enable declarative management of AI Agent Skills (from skills.sh) in the dotfiles, so that skills can be centrally defined and synchronized to all AI tools (Cursor, Claude Code, etc.).

## Requirements

- Declarative configuration (similar to Brewfile)
- Central management of custom skills
- Synchronization to multiple AI tools (Cursor, Claude, Gemini, etc.)
- Integration with existing dotfiles setup using Stow

## Implementation Ideas

### Option A: `@dhruvwill/skills-cli` (recommended)

Uses a `~/.skills/config.json` as declarative configuration:

```json
{
  "sources": [
    { "type": "remote", "url": "https://github.com/vercel-labs/agent-skills/...", "name": "frontend-design" },
    { "type": "local", "path": "~/.dotfiles/skills/custom", "name": "my-skills" }
  ],
  "targets": [
    { "name": "cursor", "path": "~/.cursor/skills" },
    { "name": "claude", "path": "~/.claude/skills" }
  ]
}
```

**Pros:**
- True declarative config (`config.json`)
- Multi-source (GitHub, GitLab, Local)
- Multi-target sync
- `skills sync` / `skills update` commands

**Cons:**
- Requires Bun runtime (not Node/npx)
- Relatively new project (6 stars)

### Option B: Official `npx skills` CLI

Direct commands in the installation script:

```bash
npx skills add vercel-labs/agent-skills --skill frontend-design -g -y
npx skills add ./custom -g --all -y
```

**Pros:**
- Official CLI from Vercel Labs
- No additional tool required

**Cons:**
- No declarative config format
- Commands must be in the script

### Proposed Structure

```
skills/
  .skills/
    config.json           # Declarative configuration (Option A)
    store/                # Central store for custom skills
      my-custom-skill/
        SKILL.md
  README.md

_install/
  skills.sh               # Installation + sync
```

### Open Questions

- [ ] Is `@dhruvwill/skills-cli` stable enough for production?
- [ ] Is Bun as a dependency acceptable? (could add to Brewfile)
- [ ] How does this behave with existing `~/.cursor/skills-cursor/` (built-in)?
- [ ] Symlink vs copy - what exactly does the CLI do?

## Dependencies

- **Option A:** Bun runtime (`brew install oven-sh/bun/bun`)
- **Option B:** Node.js (already present)
- Git (for remote sources)

## Related

- https://skills.sh/ - Agent Skills Directory
- https://github.com/vercel-labs/skills - Official CLI
- https://github.com/dhruvwill/skills-cli - Alternative CLI with config.json
- https://dhruvwill.github.io/skills-cli/ - Documentation

### Supported AI Tools

| Tool | Global Path |
|------|-------------|
| Cursor | `~/.cursor/skills/` |
| Claude Code | `~/.claude/skills/` |
| Gemini CLI | `~/.gemini/skills/` |
| OpenCode | `~/.config/opencode/skills/` |
| GitHub Copilot | `~/.copilot/skills/` |

## Notes

- Skills are reusable capabilities for AI agents (SKILL.md files)
- The official CLI supports symlink-based installation (recommended)
- Custom skills can be created locally and then synchronized
- `~/.cursor/skills-cursor/` is reserved for Cursor's built-in skills (don't touch!)

## Done Criteria

- [ ] CLI tool evaluated and decided
- [ ] Dotfiles structure created (`skills/`)
- [ ] Config file created (depending on chosen approach)
- [ ] Installation script `_install/skills.sh` created
- [ ] Integrated into `install.sh`
- [ ] README.md for skills module written
- [ ] Tested on fresh system

---

**Created:** 2026-02-05  
**Status:** Planning  
**Priority:** Medium
