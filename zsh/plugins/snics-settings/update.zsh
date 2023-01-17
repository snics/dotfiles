# Get macOS Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
update () {
    echo "Update System"
    sudo softwareupdate -i -a
    echo "Update System done!"

    echo "Update Apps"
    brew update
    brew upgrade
    # Update cask apps
    brew cu -a -y
    brew cleanup

    mas upgrade
    echo "Update Apps done!"

    echo "Update NPM modules"
    npm install npm -g
    npm update -g
    echo "Update NPM modules done!"

    echo "Update asdf plugins"
    asdf plugin update --all
    echo "Update asdf plugins done!"

    echo "Update Ruby gems"
    sudo gem update --system
    sudo gem update
    sudo gem cleanup
    echo "Update Ruby gems done!"

    if [ ! -d /usr/local/bin/helm ]; then
        echo "Update helm"
        helm-update
        echo "Update helm done!"
    fi

    echo "Update Oh My ZSH"
    omz update
    find $HOME/.oh-my-zsh/custom -type d -depth 2 -exec git --git-dir={}/.git --work-tree=/{} pull origin master \;
    echo "Update Oh My ZSH done!"

    echo "All updates done!"

    read -p "Do you want to recreate dock? (y/n) " -n 1;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdock
    fi;
}

outdated () {
    brew outdated
    brew cu -a
}
