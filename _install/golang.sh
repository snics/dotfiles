#!/usr/bin/env bash

echo "Install Golang...."

# Create a directory for Go workspace based on best practices
mkdir -p "$HOME/go"/{bin,src,pkg}

# install g (A golang version manager)
curl -sSL https://raw.githubusercontent.com/stefanmaric/g/master/bin/install | sh -s -- -y

echo "Install Golang done!"
