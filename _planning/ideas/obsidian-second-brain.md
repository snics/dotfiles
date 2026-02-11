# Obsidian Second Brain Setup

> Complete Obsidian configuration for Second Brain / PARA methodology with full automation and cross-device sync (macOS + iOS)

## 🎯 Goal

Create a fully automated, version-controlled Obsidian setup that:
- Implements the Second Brain / PARA methodology out of the box
- Syncs seamlessly between MacBook and iPhone
- Is reproducible on any new machine via dotfiles
- Includes pre-configured plugins, themes, and templates
- Matches the existing Catppuccin Mocha aesthetic

## 📋 Requirements

### Core Requirements
- Obsidian vault configuration managed in dotfiles
- Automatic installation and setup via install script
- iCloud sync for cross-device compatibility (macOS/iOS)
- PARA folder structure (Projects, Areas, Resources, Archive)
- Pre-configured essential plugins
- Catppuccin Mocha theme integration
- Ready-to-use templates for different note types

### Technical Requirements
- Configuration files in `~/.dotfiles/obsidian/`
- Installation script in `_install/obsidian.sh`
- Support for both fresh install and existing vault
- Backup mechanism for exporting current config
- Documentation in README.md

## 💡 Implementation Ideas

### Approach

1. **Phase 1: Configuration Structure**
   - Create obsidian folder structure with .obsidian config template
   - Add essential community plugins configurations
   - Create Catppuccin theme setup
   - Design note templates

2. **Phase 2: Automation**
   - Build installation script that creates vault in iCloud
   - Copy configurations from dotfiles to vault
   - Create PARA folder structure automatically
   - Add backup function for syncing config back to dotfiles

3. **Phase 3: Integration**
   - Add to main install.sh wizard
   - Update README documentation
   - Create usage guide
   - Test on fresh installation

### Folder Structure

```
obsidian/
├── .obsidian/                       # Obsidian configuration template
│   ├── plugins/                     # Community plugins
│   │   ├── dataview/
│   │   │   └── data.json
│   │   ├── templater-obsidian/
│   │   │   └── data.json
│   │   ├── calendar/
│   │   │   └── data.json
│   │   ├── periodic-notes/
│   │   │   └── data.json
│   │   ├── obsidian-git/            # Auto-backup (macOS only)
│   │   │   └── data.json
│   │   └── quick-switcher-plus/
│   │       └── data.json
│   ├── themes/
│   │   └── catppuccin/              # Catppuccin theme files
│   ├── app.json                     # Core application settings
│   ├── appearance.json              # Theme & UI settings
│   ├── community-plugins.json       # List of enabled plugins
│   ├── core-plugins.json            # Core plugins configuration
│   ├── core-plugins-migration.json
│   ├── hotkeys.json                 # Custom keyboard shortcuts
│   └── templates.json               # Template plugin settings
├── templates/                       # Note templates
│   ├── Daily Note.md
│   ├── Weekly Review.md
│   ├── Meeting Note.md
│   ├── Project.md
│   ├── Zettelkasten.md
│   └── Quick Capture.md
├── vault-structure/                 # PARA folder templates
│   ├── 00-Inbox/
│   │   └── README.md
│   ├── 01-Projects/
│   │   └── README.md
│   ├── 02-Areas/
│   │   └── README.md
│   ├── 03-Resources/
│   │   └── README.md
│   └── 04-Archive/
│       └── README.md
└── README.md                        # Obsidian setup documentation
```

### Files to Create/Modify

**New Files:**
- `obsidian/.obsidian/app.json` - Core settings (vim mode, attachments, etc.)
- `obsidian/.obsidian/appearance.json` - Catppuccin theme config
- `obsidian/.obsidian/community-plugins.json` - Plugin list
- `obsidian/.obsidian/core-plugins.json` - Core plugins config
- `obsidian/.obsidian/hotkeys.json` - Keyboard shortcuts
- `obsidian/.obsidian/templates.json` - Template settings
- `obsidian/templates/*.md` - Various note templates
- `obsidian/vault-structure/*/README.md` - Folder documentation
- `obsidian/README.md` - Setup documentation
- `_install/obsidian.sh` - Installation script
- `zsh/settings/functions/backup-obsidian.zsh` - Backup function

**Modified Files:**
- `install.sh` - Add Obsidian setup step
- `README.md` - Add Obsidian configuration section
- `brew/Brewfile` - Ensure Obsidian is installed (already present)

### Implementation Steps

#### Step 1: Create Configuration Template
1. Create base `.obsidian` folder structure
2. Configure `app.json` with sensible defaults
   - Enable vim mode
   - Set new file location to Inbox
   - Configure attachment folder
   - Enable spellcheck
3. Set up `appearance.json` for Catppuccin theme
4. Define `core-plugins.json` with essential features
5. Create `community-plugins.json` with plugin IDs

#### Step 2: Plugin Configurations
1. **Dataview** - Enable JavaScript, set refresh interval
2. **Templater** - Set template folder, configure hotkeys
3. **Calendar** - Configure daily notes location
4. **Periodic Notes** - Set up daily/weekly/monthly notes
5. **Obsidian Git** - Auto-backup settings (macOS only)
6. **Quick Switcher++** - Enhanced navigation settings

#### Step 3: Create Templates
1. **Daily Note** - Date, tasks, journal, highlights
2. **Weekly Review** - Wins, learnings, next week planning
3. **Meeting Note** - Attendees, agenda, notes, action items
4. **Project** - Goal, tasks, timeline, resources
5. **Zettelkasten** - Atomic note with backlinks
6. **Quick Capture** - Fast inbox entry

#### Step 4: Installation Script (`_install/obsidian.sh`)
```bash
#!/usr/bin/env bash

# Define paths
VAULT_NAME="SecondBrain"
ICLOUD_PATH="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
VAULT_PATH="$ICLOUD_PATH/$VAULT_NAME"
DOTFILES_OBSIDIAN="$HOME/.dotfiles/obsidian"

# Check if iCloud is available
# Create vault directory
# Copy .obsidian configuration
# Create PARA folder structure
# Copy templates
# Create README files
# Set permissions
```

#### Step 5: Backup Function
Create `backup-obsidian.zsh` to sync current vault config back to dotfiles:
```bash
function backup-obsidian() {
    # Copy .obsidian config from vault to dotfiles
    # Exclude workspace.json (changes frequently)
    # Create git commit with changes
}
```

#### Step 6: Documentation
- Add section to main README.md
- Create detailed obsidian/README.md
- Document plugin purposes
- Explain PARA methodology
- Provide iOS setup instructions

#### Step 7: Integration & Testing
- Add to install.sh wizard
- Test on fresh macOS installation
- Test iCloud sync to iOS
- Verify all plugins work
- Check templates render correctly

## 📦 Dependencies

### Already Installed
- Obsidian (via Brewfile) ✓

### Community Plugins (to configure)
- `dataview` - Query engine for notes
- `templater-obsidian` - Advanced templates
- `calendar` - Calendar view for daily notes
- `periodic-notes` - Daily/weekly/monthly notes
- `obsidian-git` - Git backup automation (macOS)
- `quick-switcher-plus` - Enhanced quick switcher

### Optional Enhancements
- `kanban` - Kanban boards
- `obsidian-excalidraw-plugin` - Drawing
- `table-editor-obsidian` - Better tables
- `tag-wrangler` - Tag management
- `obsidian-tasks-plugin` - Task management

## 🔗 Related

- [Obsidian Documentation](https://help.obsidian.md/)
- [PARA Method](https://fortelabs.com/blog/para/)
- [Second Brain](https://www.buildingasecondbrain.com/)
- [Catppuccin for Obsidian](https://github.com/catppuccin/obsidian)
- Existing: `brew/Brewfile` - Obsidian already installed
- Existing: `obsidian/` - Empty folder ready for config

## 📝 Notes

### Sync Strategy Decision
**Chose iCloud** because:
- Native macOS/iOS integration
- Zero configuration needed
- Real-time sync
- Works with existing Apple ecosystem
- No additional cost

Alternative considered:
- Obsidian Sync ($8/month) - Better but paid
- Git + Working Copy - Too complex for mobile

### Plugin Installation
Community plugins must be:
1. Enabled in `community-plugins.json`
2. Downloaded to `.obsidian/plugins/` folder
3. Configured with individual `data.json` files

For dotfiles, we'll include:
- Plugin configurations (data.json)
- Plugin list (community-plugins.json)
- User must install plugins manually first time (Obsidian security)

### Vim Mode
Enable vim mode by default in app.json since the user uses vim/neovim

### Theme Integration
Use Catppuccin Mocha to match:
- Ghostty terminal
- tmux
- lazygit
- ZSH syntax highlighting
- Entire existing setup

### Template Variables
Use Templater plugin for dynamic templates:
- `{{date}}` - Current date
- `{{time}}` - Current time
- `{{title}}` - Note title
- Custom scripts for complex logic

### Folder Structure Philosophy
PARA Method:
- **00-Inbox** - Quick capture, unsorted
- **01-Projects** - Goal-oriented, time-bound
- **02-Areas** - Ongoing responsibilities
- **03-Resources** - Reference material
- **04-Archive** - Completed/inactive

## ✅ Done Criteria

- [x] Planning document created
- [ ] `.obsidian` configuration files created
  - [ ] app.json
  - [ ] appearance.json
  - [ ] community-plugins.json
  - [ ] core-plugins.json
  - [ ] hotkeys.json
  - [ ] templates.json
- [ ] All plugin configurations created
  - [ ] dataview
  - [ ] templater
  - [ ] calendar
  - [ ] periodic-notes
  - [ ] obsidian-git
  - [ ] quick-switcher-plus
- [ ] Note templates created
  - [ ] Daily Note.md
  - [ ] Weekly Review.md
  - [ ] Meeting Note.md
  - [ ] Project.md
  - [ ] Zettelkasten.md
  - [ ] Quick Capture.md
- [ ] PARA folder structure templates created
- [ ] Installation script (`_install/obsidian.sh`) created
- [ ] Backup function (`backup-obsidian.zsh`) created
- [ ] `install.sh` updated with Obsidian step
- [ ] `README.md` updated with Obsidian section
- [ ] `obsidian/README.md` documentation created
- [ ] Catppuccin theme integrated
- [ ] Tested on fresh macOS installation
- [ ] Tested iCloud sync to iOS device
- [ ] All plugins working correctly
- [ ] Templates rendering properly
- [ ] Committed to repository with proper commit message

---

**Created:** 2025-12-05  
**Status:** Planning  
**Priority:** High

