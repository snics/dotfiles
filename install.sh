#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function doIt() {
  source ./brew/install.sh;
  source ./fonts/install.sh;

  read -p "Do you want to install Mac apps? (y/n) " -n 1;
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      source ./brew/cask-install.sh;
      source ./brew/mas.sh

      read -p "Would you like to put on my Mac Dock (y/n) " -n 1;
      echo "";
      if [[ $REPLY =~ ^[Yy]$ ]]; then
          source ./macOS/dock.sh;
      fi;

      read -p "Do you want to use Alred 4? (y/n) " -n 1;
      if [[ $REPLY =~ ^[Yy]$ ]]; then
          source ./alfred/settings.sh
      fi;
  fi;

  read -p "Do you want to use my zsh and oh-my-zsh settings? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      source ./zsh/install.sh
  fi;

  read -p "Do you want to use Node.js? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      source ./node/install.sh
  fi;

  read -p "Do you want to use Docker? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      source ./docker/install.sh
  fi;

  read -p "Do you want to use Flutter? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      source ./flutter/install.sh
  fi;

  read -p "Do you want to use Kotlin? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      source ./kotlin/install.sh
  fi;

  read -p "Do you want to use asdf? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      source ./asdf/install.sh

      read -p "Do you want to install my asdf plugins (y/n) " -n 1;
      echo "";
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        source ./asdf/dock.sh;
      fi;
  fi;

  read -p "Would you like to use Mackup? (Keep your application settings in sync (OS X/Linux). https://github.com/lra/mackup) (y/n)" -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      source ./mackup/install.sh
  fi;

  read -p "Do you want to use Vim and NeoVim? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      source ./nvim/install.sh
  fi;

  read -p "Do you want to have my Development/Project folder structure? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      source ./macOS/project-folder-structure.sh
  fi;

  source ./git/settings.sh;
  source ./macOS/settings.sh;

  echo ""
  echo "Set your user tokens as environment variables, such as ~/.secrets"
  echo "See the README for examples."

  read -p "Do you want to restart your Mac (This is recommended now)? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo reboot
  fi;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    doIt;
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt;
    fi;
fi;
unset doIt;
