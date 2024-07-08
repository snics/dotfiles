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

# Create a directory for Go workspace based on best practices
mkdir -p $HOME/go/{bin,src,pkg}

# Utils
## Installing Delve, a debugger for Go
brew install "delve"

## Installing gopls (Go Language Server), useful for IDEs and editors supporting LSP
brew install "gopls"

## Installing Gox, a cross-compilation tool for Go
brew install "gox"

# install g (A golang version manager)
curl -sSL https://git.io/g-install | sh -s -- -y

## Remove outdated versions from the cellar.
brew cleanup

echo ""
echo "Install Golang done!"
echo ""
