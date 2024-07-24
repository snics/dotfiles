#!/usr/bin/env bash

echo -e "Install Golang...."

# Create a directory for Go workspace based on best practices
mkdir -p $HOME/go/{bin,src,pkg}

# install g (A golang version manager)
curl -sSL https://git.io/g-install | sh -s -- -y


echo "Install Golang done!"