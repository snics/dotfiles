#!/usr/bin/env bash

echo -e "\\n\\nSetup Dev folder structure..."
echo ""

# Global Dev Scope
[ ! -d "$HOME/Projects" ] && mkdir -p "$HOME/Projects"

# Scope for projects at GitHub.
[ ! -d "$HOME/Projects/GitHub" ] && mkdir -p "$HOME/Projects/GitHub"

# Central location for git worktrees (herdr/sessionizer create them here).
[ ! -d "$HOME/Projects/_worktrees" ] && mkdir -p "$HOME/Projects/_worktrees"

# Scope for Client Projects.
if [ ! -d "$HOME/Projects/Clients" ]
then
	read -r -p"Are you self-employed or do you have customers? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p "$HOME/Projects/Clients"
  fi;
	echo -e "\\n";
fi

# Scope for Startup Projects.
if [ ! -d "$HOME/Projects/Startups" ]
then
	read -r -p"Are you involved in start-ups or do you hold company shares? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p "$HOME/Projects/Startups"
  fi;
	echo -e "\\n";
fi

# Scope for Talks/Meetups/Lecturer work.
if [ ! -d "$HOME/Projects/Talks" ]
then
	read -r -p"Are you a lecturer or a speaker? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p "$HOME/Projects/Talks"
  fi;
	echo -e "\\n";
fi

# Scope for Workshop materials.
if [ ! -d "$HOME/Projects/Workshop" ]
then
	read -r -p"Do you conduct workshops or training sessions? (y/n) " -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p "$HOME/Projects/Workshop"
  fi;
	echo -e "\\n";
fi

echo ""
echo "Setup Dev folder structure done!"
echo ""
