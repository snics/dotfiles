#!/usr/bin/env bash

echo -e "\\n\\nInstall Rust...."
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

# Installing Golang
brew install "rustup-init"

rustup-init --default-toolchain=nightly -y

## Remove outdated versions from the cellar.
brew cleanup

echo ""
echo "Install Rust done!"
echo ""
