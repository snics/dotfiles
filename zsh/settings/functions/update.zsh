# Main update function
update() {
  update_all=false
  dock=false

  # Update system using macOS softwareupdate command
  _updateSystem() {
    sudo softwareupdate -i -a
  }

  # Update Homebrew, upgrade packages, update cask apps, and cleanup
  _updateBrew() {
    echo "🍺 Updating Homebrew..."
    brew update
    brew upgrade
    # Update cask apps
    echo "🍹 Updating Cask apps..."
    brew cu -a -y
    brew cleanup
  }

  # Update Mac App Store apps using mas
  _updateMas() {
    echo "🍎 Updating Mac App Store apps..."
    mas upgrade
  }

  # Update npm and globally installed npm modules
  _updateNpm() {
    npm install npm -g
    npm update -g
  }

  # Update all asdf plugins
  _updateAsdf() {
    asdf plugin update --all
  }

  # Update RubyGems and installed gems
  _updateRubyGems() {
    sudo gem update --system
    sudo gem update
    sudo gem cleanup
  }

  # Update Oh My Zsh and zplug plugins
  _updateZshAndZim() {
    zimfw update
    zimfw upgrade
  }

  # Ask user whether to update a specific category
  # Ask user whether to update a specific category
  _ask_update() {
    category="$1"
    emoji="$2"
    if [ "$update_all" = true ]; then
      return 0
    else
      echo -n "${emoji} ${category}: Do you want to update this? [yes/no]:"
      read answer
      [[ "$answer" =~ ^[Yy] ]]
    fi
  }

  # Recreate dock if user wants to
  _mack_dock() {
    if [ "$dock" = true ]; then
      dock
    else
      echo -n "🚢 Do you want to recreate dock? [yes/no]:"
      read answer
      if [[ $answer =~ ^[Yy] ]]; then
        dock
      fi
    fi
  }

    # Parse command line options
  for arg in "$@"
  do
    case $arg in
      -y|--all)
        update_all=true
        shift
        ;;
      -d|--dock)
        dock=true
        shift
        ;;
    esac
  done

  # Ask for sudo password and keep sudo session alive
  echo "Please enter your password:"
  sudo -v >/dev/null 2>&1

  # Update categories based on user input or command line options
  if _ask_update "1. System" "🖥️"; then
    echo "🖥️ Updating system..."
    _updateSystem
    echo "Updating system done!"
  fi

  if _ask_update "2. Mac Apps" "🍎"; then
    echo "🍎 Updating mac apps..."
    _updateBrew
    _updateMas
    echo "Updating mac apps done!"
  fi

  if _ask_update "3. NPM Modules" "🟩"; then
    echo "🟩 Updating NPM modules..."
    _updateNpm
    echo "Updating NPM modules done!"
  fi

  if _ask_update "4. Asdf Plugins" "🔌"; then
    echo "🔌 Updating asdf plugins..."
    _updateAsdf
    echo "Updating asdf plugins done!"
  fi

  if _ask_update "5. Ruby Gems" "💎"; then
    echo "💎 Updating Ruby Gems..."
    _updateRubyGems
    echo "Updating Ruby Gems done!"
  fi

  if _ask_update "7. Zsh and zim" "🐚"; then
    echo "🐚 Updating Zsh and zim..."
    _updateOhMyZsh
    echo "Updating Zsh and zim done!"
  fi

  _mack_dock
}

# Function to show outdated Homebrew packages and cask apps
outdated() {
  brew outdated
  brew cu -a9
}
