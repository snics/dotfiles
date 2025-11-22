#!/usr/bin/env bash

echo -e "\\n\\nSetup Dev folder structure..."
echo ""

# Globle Dev Scope
[ ! -d "$HOME/Projects" ] && mkdir -p "$HOME/Projects"

# Scope for projects at GitHub.
[ ! -d "$HOME/Projects/GitHub" ] && mkdir -p "$HOME/Projects/GitHub"
[ ! -d "$HOME/Projects/GitHub" ] && mkdir -p "$HOME/Projects/GitHub/raycast-extensions"

# Scope for projects at GitLab.
[ ! -d "$HOME/Projects/GitLab" ] && mkdir -p "$HOME/Projects/GitLab"

# Scope for things that are not so important (Testing/Git Clone and so on..).
[ ! -d "$HOME/Projects/Throwaway" ] && mkdir -p "$HOME/Projects/Throwaway"

# Scope for helpful scripts that make life easier.
[ ! -d "$HOME/Projects/Scripts" ] && mkdir -p "$HOME/Projects/Scripts"

# Scope for helpful tools that make life easier.
[ ! -d "$HOME/Projects/Tools" ] && mkdir -p "$HOME/Projects/Tools"

# Scope for programming languages or dev things I want to try or learn.
[ ! -d "$HOME/Projects/Learning" ] && mkdir -p "$HOME/Projects/Learning"

# Scope for Client Project.
if [ ! -d "$HOME/Projects/Clients" ]
then
	read -p "Are you self-employed or do you have customers? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p "$HOME/Projects/Clients"
  fi;
	echo -e "\\n";
fi

# Scope for Startups Project.
if [ ! -d "$HOME/Projects/Startups" ]
then
	read -p "Are they involved in start-ups or have shares from companies? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p "$HOME/Projects/Startups"
  fi;
	echo -e "\\n";
fi

# Scope for Non-Profit organizations.
if [ ! -d "$HOME/Projects/Non-Profit" ]
then
	read -p "Do you work on non-profit organization projects? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p "$HOME/Projects/Non-Profit"
  fi;
	echo -e "\\n";
fi

# Scope for Talks/Meetups/Lecturer work.
if [ ! -d "$HOME/Projects/Talks" ]
then
	read -p "Are you a lecturer or a speaker? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p "$HOME/Projects/Talks"
  fi;
	echo -e "\\n";
fi

# Scope for Workshop materials.
if [ ! -d "$HOME/Projects/Workshop" ]
then
	read -p "Do you conduct workshops or training sessions? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p "$HOME/Projects/Workshop"
  fi;
	echo -e "\\n";
fi

echo ""
echo "Setup Dev folder structure done!"
echo ""
