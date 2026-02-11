# Planning & Roadmap

This directory contains planning and roadmap for future improvements and features for the dotfiles project.

## 📂 Structure

- **`backlog.md`** - Main to-do list and roadmap with all planned tasks and ideas
- **`ideas/`** - Detailed planning documents for specific features
  - **`_ideas-template.md`** - Template for creating new feature planning documents

## 🎯 How to Use

### Working with the Backlog & Roadmap

The `backlog.md` serves as both your to-do list and roadmap. It contains:

- **Currently Working On** - Items actively being worked on (2-5 items)
- **To Do** - Simple unordered list of all planned tasks
- **Recently Completed** - Archive of finished items

Work on items when time and motivation align. Move items from "To Do" to "Currently Working On" when you start them.

### Creating Detailed Plans

For complex features that need more planning:

1. Copy `ideas/_ideas-template.md` to `ideas/feature-name.md`
2. Fill in all sections with your planning details
3. Link to it from the backlog: `→ [Details](ideas/feature-name.md)`

The template provides a consistent structure for all detailed feature plans.

## 📝 Writing To-Do Items

### Format Structure

```markdown
- [ ] {emoji} **{Module}** - {Description} → [Details](ideas/xyz.md) · [📁 Files](path/to/files)
```

### Emoji Conventions (Git Commit Style)

Use emojis to indicate the type of work:

| Emoji | Type | When to Use |
|-------|------|-------------|
| ✨ | feat | New feature implementation |
| 🐛 | fix | Bug fixes |
| 📝 | docs | Documentation writing/improvements |
| 🎨 | theme | Styling and theming changes |
| ♻️ | refactor | Code restructuring |
| 🔧 | config | Configuration adjustments |
| 🛠️ | tool | Tool integration |
| 🤖 | automation | Automation scripts |
| 🔐 | security | Security improvements |
| 🧪 | test | Adding tests |
| ⚡ | perf | Performance improvements |
| 🗑️ | remove | Removing code/features |

### Module/Area Names

Use consistent module names in **bold**:

- **asdf** - Version Manager
- **tmux** - Terminal Multiplexer
- **zsh** - Shell Configuration
- **git** - Git Configuration
- **nvim** - Neovim Editor
- **brew** - Homebrew/Packages
- **macOS** - macOS System Settings
- **docs** - Documentation
- **install** - Installation Scripts
- **backup** - Backup System
- **theme** - Theming System
- **k8s** - Kubernetes Tools
- **docker** - Container Tools
- **vscode** - VS Code Integration
- **general** - General improvements

### Link Types

Add optional links for additional context:

- `→ [Details](ideas/feature.md)` - Link to detailed planning document
- `· [📁 Files](path/to/module)` - Link to affected files/directory
- `· [📄 Script](path/script.sh)` - Link to specific script

### Rules & Best Practices

1. **Emoji first** - Shows type at a glance
2. **Module in bold** - Quick orientation which area
3. **Short, active description** - What will be done?
4. **Links optional** - Only when useful/available
5. **Multiple links** - Separate with ` · `
6. **Keep it simple** - One item = one actionable task

## 💡 Examples

### Good Examples

```markdown
- [ ] 🔧 **asdf** - Remove nvm and helm custom configs → [Details](ideas/asdf-migration.md) · [📁 Files](../asdf)
- [ ] 📝 **docs** - Create keyboard shortcuts reference for all tools
- [ ] ✨ **vscode** - Add settings, extensions and keybindings → [Details](ideas/vscode-integration.md)
- [ ] 🎨 **theme** - Create theme switcher script between color schemes · [📁 Files](../zsh/themes)
- [ ] 🛠️ **tmux** - Finalize setup and document plugins · [📁 Files](../tmux)
- [ ] 🤖 **automation** - Add automated backup script for dotfiles
- [ ] 🔐 **security** - Integrate 1Password CLI for secrets management
- [ ] 📝 **docs** - Add troubleshooting guide with common issues
- [ ] ♻️ **zsh** - Refactor functions into separate module files · [📁 Files](../zsh/settings/functions)
- [ ] 🗑️ **brew** - Remove unused packages from Brewfile · [📄 File](../brew/Brewfile)
```

### Bad Examples (Don't Do This)

```markdown
❌ - [ ] fix stuff (no emoji, no module, too vague)
❌ - [ ] **tmux** Update configuration (no emoji, not clear what to update)
❌ - [ ] 📝 Write docs (no module, too vague)
❌ - [ ] 🔧 asdf - Remove nvm (module not bold)
❌ - [ ] Do something with themes maybe (no emoji, no module, unclear)
```

## 🔄 Workflow

```
1. Add new idea to backlog.md "To Do" section
2. Use format: emoji + module + description + optional links
3. If complex → create detailed plan in ideas/
4. When starting work → move to "Currently Working On"
5. Work on the item step by step
6. Check it off when complete: [x]
7. Move to "Recently Completed" section
8. Commit your progress
9. Let AI help implement based on planning docs
```

## 📋 Tips

- Keep items actionable and specific
- Use detailed planning docs for complex features
- Commit planning changes separately from implementation
- Link related items together
- Review backlog regularly
- Archive old completed items periodically
- Don't overthink it - just start and adjust as needed!