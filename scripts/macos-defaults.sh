#!/bin/zsh
#
# macos-defaults.sh — macOS system preferences for a fresh Mac
#
# Applies the Finder / Dock / keyboard / screenshot tweaks I settle a new
# machine into. Everything here is a `defaults write` (or equivalent), so the
# script is idempotent — safe to run as many times as you like.
#
# Usage:  ./scripts/macos-defaults.sh
#
# Notes:
#   - Finder, Dock, and SystemUIServer are restarted at the end so changes
#     take effect immediately.
#   - The keyboard repeat settings only fully apply after a logout/login.
#   - Undo any single setting with:  defaults delete <domain> <key>
#
# First applied: 2026-07-04

set -u

echo "Applying macOS defaults…"

##############################################################################
# Dock
##############################################################################

# Reveal the Dock instantly on hover — no delay, no slide animation.
# Requires Dock autohide to be on (System Settings ▸ Desktop & Dock, or ⌥⌘D).
# For a fast-but-visible slide instead of an instant snap, use 0.15 here:
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

# Minimize windows into their app icon instead of a separate Dock tile.
defaults write com.apple.dock minimize-to-application -bool true

# Drop the "recent applications" section from the Dock.
defaults write com.apple.dock show-recents -bool false

# Stop Spaces from auto-reordering by most-recent use.
defaults write com.apple.dock mru-spaces -bool false

##############################################################################
# Finder
##############################################################################

# Show the Path Bar (clickable breadcrumb trail) at the bottom of windows.
defaults write com.apple.finder ShowPathbar -bool true

# Show the status bar (item count + free space).
defaults write com.apple.finder ShowStatusBar -bool true

# Always show file extensions.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Keep folders on top when sorting by name.
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Search the current folder by default, not the whole Mac.
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Default to list view. Other codes: icnv=icon, clmv=column, Flwv=gallery.
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show hidden (dot) files. Toggle live anytime with ⌘⇧.
defaults write com.apple.finder AppleShowAllFiles -bool true

# Don't litter network / USB volumes with .DS_Store files.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Unhide the ~/Library folder.
chflags nohidden "${HOME}/Library"

##############################################################################
# Keyboard  (fully effective after a logout/login)
##############################################################################

# Hold a key to repeat it, instead of showing the accent picker.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Fast key repeat + short delay before repeat kicks in.
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

##############################################################################
# Dialogs & saving
##############################################################################

# Expand the Save and Print panels by default.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# Save new documents to disk (not iCloud) by default.
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

##############################################################################
# Screenshots
##############################################################################

# Save screenshots to ~/Pictures/Screenshots as PNG.
mkdir -p "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"

##############################################################################
# Apply
##############################################################################

# Restart the affected apps so changes take effect now.
for app in Dock Finder SystemUIServer; do
    killall "${app}" >/dev/null 2>&1 || true
done

echo "Done. Log out and back in for the keyboard repeat settings to fully apply."
