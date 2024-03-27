#!/usr/bin/env bash

echo -e "\\n\\nInstall homebrew cask formulae...."
echo ""

which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we’re using the latest Homebrew.
brew update
# Upgrade any already-installed formulae.
brew upgrade
brew cask upgrade


# Install command-line tools using Homebrew.
brew tap "homebrew/cask"
brew tap "homebrew/cask-fonts"
brew tap "homebrew/cask-versions"
brew tap "buo/cask-upgrade"
brew tap "homebrew/command-not-found"

# Utils
brew install --cask "1password"
brew install --cask "1password-cli"
brew install --cask "spotify"
brew install --cask "raycast"
brew install --cask "superhuman"
brew install --cask "cheatsheet"
brew install --cask "vlc"
brew install --cask "bartender"
brew install --cask "bettertouchtool"
brew install --cask "cardhop"
brew install --cask "fantastical"
brew install --cask "franz"
brew install --cask "discord"
brew install --cask "zoom"
brew install --cask "mountain-duck"
brew install --cask "cleanmymac"
brew install --cask "gemini"
brew install --cask "the-unarchiver"
brew install --cask "istat-menus"
brew install --cask "gifox"
brew install --cask "keepingyouawake"
brew install --cask "numi"
brew install --cask "keyboard-maestro"
brew install --cask "mission-control-plus"
brew install --cask "coconutbattery"
brew install --cask "sipgate-softphone"
brew install --cask "macfuse"
brew install --cask "notion"
brew install --cask "miro"

# Browsers
brew install --cask "google-chrome"
brew install --cask "chromium"
brew install --cask "firefox"
brew install --cask "opera"
brew install --cask "tor-browser"

# Microsoft Office
brew install --cask "microsoft-excel"
brew install --cask "microsoft-powerpoint"
brew install --cask "microsoft-word"

# Developer Tools
brew install --cask "jetbrains-toolbox"
brew install --cask "visual-studio-code"
brew install --cask "iterm2"
brew install --cask "kaleidoscope"
brew install --cask "macdown"
brew install --cask "rapidapi"
brew install --cask "proxyman"
brew install --cask "istumbler"
brew install --cask "gitkraken"
brew install --cask "gpg-suite"
brew install --cask "transmit"
brew install --cask "imageoptim"
brew install --cask "dash"
brew install --cask "parallels"
brew install --cask "parallels-access"

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew install --cask "qlcolorcode"
brew install --cask "qlimagesize"
brew install --cask "qlmarkdown"
brew install --cask "qlstephen"
brew install --cask "qlvideo"
brew install --cask "quicklook-json"
brew install --cask "suspicious-package"
brew install --cask "webpquicklook"
brew install --cask "quicklookase"

# Media programmes
brew install --cask "obs"
brew install --cask "switchresx"
brew install --cask "kap"
brew install --cask "loopback"
brew install --cask "fission"
brew install --cask "audio-hijack"
brew install --cask "farrago"

# Remove outdated versions from the cellar.
brew cleanup

echo ""
echo "Install homebrew cask formulae done!"
echo ""
