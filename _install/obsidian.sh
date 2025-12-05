#!/usr/bin/env bash

echo "📝 Setting up Obsidian for Second Brain..."

# Define paths
VAULT_NAME="SecondBrain"
ICLOUD_PATH="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
VAULT_PATH="$ICLOUD_PATH/$VAULT_NAME"
DOTFILES_OBSIDIAN="$HOME/.dotfiles/obsidian"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if iCloud Drive is available
if [ ! -d "$HOME/Library/Mobile Documents" ]; then
    print_error "iCloud Drive not found. Please enable iCloud Drive in System Settings."
    exit 1
fi

# Check if Obsidian iCloud folder exists
if [ ! -d "$ICLOUD_PATH" ]; then
    print_warning "Obsidian iCloud folder not found at: $ICLOUD_PATH"
    print_warning "This will be created when you first launch Obsidian."
    print_warning "Please:"
    echo "  1. Open Obsidian"
    echo "  2. Enable iCloud sync when prompted"
    echo "  3. Run this script again"
    exit 1
fi

# Create vault directory if it doesn't exist
if [ ! -d "$VAULT_PATH" ]; then
    echo "Creating Obsidian vault at: $VAULT_PATH"
    mkdir -p "$VAULT_PATH"
    print_success "Vault directory created"
else
    print_warning "Vault already exists at: $VAULT_PATH"
    read -p "Do you want to overwrite existing configuration? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Copy .obsidian configuration
echo "Copying Obsidian configuration..."
if [ -d "$DOTFILES_OBSIDIAN/.obsidian" ]; then
    # Remove existing .obsidian folder if it exists
    if [ -d "$VAULT_PATH/.obsidian" ]; then
        rm -rf "$VAULT_PATH/.obsidian"
    fi
    
    cp -R "$DOTFILES_OBSIDIAN/.obsidian" "$VAULT_PATH/"
    print_success "Configuration copied"
else
    print_error "Configuration not found in dotfiles"
    exit 1
fi

# Copy templates
echo "Copying note templates..."
if [ -d "$DOTFILES_OBSIDIAN/templates" ]; then
    cp -R "$DOTFILES_OBSIDIAN/templates" "$VAULT_PATH/"
    print_success "Templates copied"
else
    print_warning "Templates not found in dotfiles"
fi

# Create PARA folder structure
echo "Creating PARA folder structure..."
mkdir -p "$VAULT_PATH/00-Inbox"
mkdir -p "$VAULT_PATH/01-Projects"
mkdir -p "$VAULT_PATH/02-Areas/Daily Notes"
mkdir -p "$VAULT_PATH/02-Areas/Weekly Notes"
mkdir -p "$VAULT_PATH/02-Areas/Development"
mkdir -p "$VAULT_PATH/02-Areas/Health"
mkdir -p "$VAULT_PATH/02-Areas/Personal"
mkdir -p "$VAULT_PATH/03-Resources/Books"
mkdir -p "$VAULT_PATH/03-Resources/Articles"
mkdir -p "$VAULT_PATH/03-Resources/Courses"
mkdir -p "$VAULT_PATH/03-Resources/Tools"
mkdir -p "$VAULT_PATH/04-Archive/Projects"
mkdir -p "$VAULT_PATH/attachments"
print_success "PARA structure created"

# Copy README files to PARA folders
echo "Copying folder documentation..."
if [ -d "$DOTFILES_OBSIDIAN/vault-structure" ]; then
    cp "$DOTFILES_OBSIDIAN/vault-structure/00-Inbox/README.md" "$VAULT_PATH/00-Inbox/" 2>/dev/null
    cp "$DOTFILES_OBSIDIAN/vault-structure/01-Projects/README.md" "$VAULT_PATH/01-Projects/" 2>/dev/null
    cp "$DOTFILES_OBSIDIAN/vault-structure/02-Areas/README.md" "$VAULT_PATH/02-Areas/" 2>/dev/null
    cp "$DOTFILES_OBSIDIAN/vault-structure/03-Resources/README.md" "$VAULT_PATH/03-Resources/" 2>/dev/null
    cp "$DOTFILES_OBSIDIAN/vault-structure/04-Archive/README.md" "$VAULT_PATH/04-Archive/" 2>/dev/null
    print_success "Folder documentation copied"
fi

# Create a welcome note
cat > "$VAULT_PATH/Welcome to Your Second Brain.md" << 'EOF'
---
date: $(date +%Y-%m-%d)
tags: [welcome, setup]
---

# 🧠 Welcome to Your Second Brain

This Obsidian vault is configured for the PARA methodology (Projects, Areas, Resources, Archive).

## 📁 Folder Structure

- **00-Inbox** - Quick capture for all incoming thoughts and ideas
- **01-Projects** - Active projects with specific goals and deadlines
- **02-Areas** - Ongoing responsibilities (Health, Development, etc.)
- **03-Resources** - Reference materials and knowledge base
- **04-Archive** - Completed projects and inactive items

## 🚀 Getting Started

1. **Install Community Plugins**
   - Go to Settings → Community Plugins
   - Turn off Safe Mode
   - Install: Dataview, Templater, Calendar, Periodic Notes, Obsidian Git, Quick Switcher++

2. **Install Catppuccin Theme**
   - Settings → Appearance → Themes
   - Search for "Catppuccin" and install
   - Select "Mocha" flavor

3. **Start Capturing**
   - Use `Cmd+N` for new notes
   - Use `Cmd+Shift+D` for daily notes
   - Use `Cmd+Shift+T` to insert templates

## 📝 Templates Available

- Daily Note - For daily journaling and task tracking
- Weekly Review - For weekly reflections
- Meeting Note - For meeting minutes
- Project - For project planning
- Zettelkasten - For atomic knowledge notes
- Quick Capture - For fast inbox entries

## ⌨️ Keyboard Shortcuts

- `Cmd+P` - Quick switcher
- `Cmd+Shift+P` - Command palette  
- `Cmd+E` - Toggle edit/preview
- `Cmd+B` - Bold text
- `Cmd+I` - Italic text
- `Cmd+L` - Toggle checkbox
- `Cmd+\` - Split pane vertically

## 🎯 Workflow Suggestions

1. **Daily** - Start with daily note, capture in Inbox
2. **Weekly** - Review Inbox, sort into PARA, do weekly review
3. **Monthly** - Archive completed projects, review progress

## 📚 Learn More

- [PARA Method](https://fortelabs.com/blog/para/)
- [Building a Second Brain](https://www.buildingasecondbrain.com/)
- [Obsidian Help](https://help.obsidian.md/)

---

**Vault Location:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/SecondBrain`
**Dotfiles:** `~/.dotfiles/obsidian`
**Backup Function:** `backup-obsidian` (in terminal)
EOF

print_success "Welcome note created"

# Set proper permissions
chmod -R 755 "$VAULT_PATH"

echo ""
print_success "Obsidian setup complete!"
echo ""
echo "📍 Vault location: $VAULT_PATH"
echo ""
echo "Next steps:"
echo "  1. Open Obsidian"
echo "  2. Open existing vault: $VAULT_PATH"
echo "  3. Install community plugins (Settings → Community Plugins)"
echo "  4. Install Catppuccin theme (Settings → Appearance → Themes)"
echo "  5. On iOS: Open Obsidian app and select the vault from iCloud"
echo ""
echo "Useful commands:"
echo "  backup-obsidian  - Backup current vault config to dotfiles"
echo ""

