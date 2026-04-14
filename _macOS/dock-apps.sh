#!/usr/bin/env bash
# =============================================================================
# Central Dock Configuration
# =============================================================================
#
# This file defines the apps and folders in the macOS Dock.
# Used by two scripts:
#   - macOS/dock.sh             (initial installation)
#   - zsh/functions/mkdock.zsh  (shell command: mkdock / dock)
#
# =============================================================================
# DOCK_APPS - Apps in the Dock
# =============================================================================
#
# Format:
#   - Full path to the .app file
#   - "SPACER" for a gap/separator between app groups
#
# Adding apps:
#   Simply add the path to the app in the list, e.g.:
#   "/Applications/Visual Studio Code.app"
#
# Removing apps:
#   Delete or comment out the line with the app path.
#
# Order:
#   Apps appear in the Dock in the order defined here (top = left).
#
# Finding app paths:
#   In terminal: ls /Applications/ or ls /System/Applications/
#
# =============================================================================
# DOCK_FOLDERS - Folders on the right side of the Dock (next to Trash)
# =============================================================================
#
# Format: "path|view|display|sort"
#
#   path    - Path to the folder ($HOME for home directory)
#   view    - View style: list, grid, fan, auto
#   display - Display as: folder, stack
#   sort    - Sort by: name, dateadded, datemodified, datecreated, kind
#
# Example:
#   "$HOME/Downloads|list|folder|dateadded"
#
# =============================================================================

# shellcheck disable=SC2034
DOCK_APPS=(
    "/System/Applications/System Settings.app"
    "/Applications/Spotify.app"
    "SPACER"
    "/Applications/Google Chrome.app"
    "/Applications/Arc.app"
    "SPACER"
    "/Applications/Superhuman.app"
    "/Applications/Notion Calendar.app"
    "/Applications/Notion.app"
    "/Applications/Slack.app"
    "SPACER"
    "/Applications/Obsidian.app"
    "/Applications/Reader.app"
    "/Applications/Ghostty.app"
    "/Applications/Zed.app"
    "/Applications/GitKraken.app"
    "SPACER"
)

# shellcheck disable=SC2034
DOCK_FOLDERS=(
    "$HOME/Projects|list|folder|name"
    "$HOME/Downloads|list|folder|dateadded"
    "/Applications|grid|folder|name"
)
