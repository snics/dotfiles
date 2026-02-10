#!/usr/bin/env zsh

# Backup Obsidian vault configuration to dotfiles
#
# This function copies the current Obsidian vault configuration
# from iCloud back to your dotfiles repository.
#
# Usage: backup-obsidian

function backup-obsidian() {
    local VAULT_NAME="SecondBrain"
    local ICLOUD_PATH="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
    local VAULT_PATH="$ICLOUD_PATH/$VAULT_NAME"
    local DOTFILES_OBSIDIAN="$HOME/.dotfiles/obsidian"
    
    # Colors
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local RED='\033[0;31m'
    local NC='\033[0m'
    
    echo "📝 Backing up Obsidian configuration..."
    echo ""
    
    # Check if vault exists
    if [ ! -d "$VAULT_PATH" ]; then
        echo -e "${RED}✗${NC} Vault not found at: $VAULT_PATH"
        return 1
    fi
    
    # Check if .obsidian folder exists
    if [ ! -d "$VAULT_PATH/.obsidian" ]; then
        echo -e "${RED}✗${NC} .obsidian configuration not found in vault"
        return 1
    fi
    
    # Backup .obsidian configuration
    echo "Copying .obsidian configuration..."
    
    # Remove old config in dotfiles
    if [ -d "$DOTFILES_OBSIDIAN/.obsidian" ]; then
        rm -rf "$DOTFILES_OBSIDIAN/.obsidian"
    fi
    
    # Copy new config, excluding workspace.json and workspace-mobile.json
    mkdir -p "$DOTFILES_OBSIDIAN/.obsidian"
    
    # Copy all files except workspace files (they change too frequently)
    rsync -av \
        --exclude='workspace.json' \
        --exclude='workspace-mobile.json' \
        --exclude='workspace.json.bak' \
        --exclude='*.sync-conflict*' \
        "$VAULT_PATH/.obsidian/" \
        "$DOTFILES_OBSIDIAN/.obsidian/"
    
    echo -e "${GREEN}✓${NC} Configuration backed up"
    
    # Backup templates if they've changed
    if [ -d "$VAULT_PATH/templates" ]; then
        echo "Copying templates..."
        rsync -av --delete "$VAULT_PATH/templates/" "$DOTFILES_OBSIDIAN/templates/"
        echo -e "${GREEN}✓${NC} Templates backed up"
    fi
    
    # Show what changed
    echo ""
    echo "Changes in dotfiles:"
    cd "$DOTFILES_OBSIDIAN" && git status --short
    
    echo ""
    echo -e "${GREEN}✓${NC} Backup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Review changes: cd ~/.dotfiles/obsidian && git diff"
    echo "  2. Commit changes: git add . && git commit -m '🔧 Update Obsidian configuration'"
    echo "  3. Push to remote: git push"
    echo ""
}

