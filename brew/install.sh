#!/usr/bin/env bash

echo -e "\\n\\nInstall homebrew formulae...."
echo ""

# Install command-line tools using Homebrew.
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

brew tap "homebrew/cask"
brew tap "homebrew/cask-fonts"
brew tap "homebrew/cask-versions"
brew tap "buo/cask-upgrade"
brew tap "homebrew/command-not-found"

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed
# Install a modern version of Bash.
brew install bash
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

# Install `wget` with IRI support.
brew install wget

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install more recent versions of some macOS tools.
brew install grep
brew install openssh
brew install screen
brew install php
brew install gmp

# Install font tools.
brew tap bramstein/webfonttools
brew install sfnt2woff
brew install sfnt2woff-zopfli
brew install woff2

# Install some CTF tools; see https://github.com/ctfs/write-ups.
brew install aircrack-ng
brew install bfg
brew install binutils
brew install binwalk
brew install cifer
brew install dex2jar
brew install dns2tcp
brew install fcrackzip
brew install foremost
brew install hashpump
brew install hydra
brew install john
brew install knock
brew install netpbm
brew install nmap
brew install pngcheck
brew install socat
brew install sqlmap
brew install tcpflow
brew install tcpreplay
brew install tcptrace
brew install ucspi-tcp # `tcpserver` etc.
brew install xpdf
brew install xz

# Packages
brew install bat
brew install cloc
brew install diff-so-fancy
brew install entr
brew install exa
brew install fd
brew install fzf
brew install gh
brew install gnupg
brew install highlight
brew install htop
brew install hub
brew install lazydocker
brew install lazygit
brew install markdown
brew install neofetch
brew install nmap
brew install python
brew install reattach-to-user-namespace
brew install ripgrep
brew install shellcheck
brew install the_silver_searcher
brew install tig
brew install tldr
brew install tmux
brew install trash
brew install wdiff
brew install yarn
brew install z
brew install --cask macfuse
brew install ntfs-3g
brew install ntfs-3g-mac
brew install pandoc

# Install other useful binaries.
brew install ack
brew install exiv2
brew install git
brew install git-lfs
brew install gs
brew install imagemagick
brew install lua
brew install lynx
brew install p7zip
brew install pigz
brew install pv
brew install rename
brew install rlwrap
brew install ssh-copy-id
brew install tree
brew install jq
brew install vbindiff
brew install zopfli
brew install dockutil
brew install rke
brew install awscli
brew install s3cmd
brew install minio-mc


# Remove outdated versions from the cellar.
brew cleanup

echo ""
echo "Install homebrew formulae done!"
echo ""
