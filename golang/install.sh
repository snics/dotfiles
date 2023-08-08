#!/usr/bin/env bash

echo -e "\\n\\nInstall Golang...."
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
brew install "go"


# Utils
## Installing Delve, a debugger for Go
brew install "delve"

## Installing gopls (Go Language Server), useful for IDEs and editors supporting LSP
brew install "gopls"

## Installing Gox, a cross-compilation tool for Go
brew install "gox"

## Remove outdated versions from the cellar.
brew cleanup

echo ""
echo "Install Golang done!"
echo ""
