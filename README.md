# Nico's dotfiles

## Installation

**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

````bash
sh -c "`curl -fsSL https://raw.githubusercontent.com/snics/dotfiles/master/install.sh`"
````
## Install Homebrew formulae
When setting up a new Mac, you may want to install some common [Homebrew](https://brew.sh/) formulae (after installing Homebrew, of course):

```bash
./brew/install.sh
```

#### Install Homebrew cask formulae

```bash
./brew/cask-install.sh
```

#### Install App Store Apps:
```bash
./brew/mas.sh
```

## Sensible macOS defaults

When setting up a new Mac, you may want to set some sensible macOS defaults:
```bash
./MacOS/settings.sh
```

#### Sensible macOS dock defaults:

```bash
./MacOS/dock.sh
```

## Feedback

Suggestions/improvements
[welcome](https://github.com/snics/dotfiles/issues)!

## Author

| [![twitter/NicoSwiatecki](http://gravatar.com/avatar/23a38342df4d30085f1bbe71058cc89b?s=70)](http://twitter.com/NicoSwiatecki "Follow @NicoSwiatecki on Twitter") |
|---|
| [Nico Swiatecki](https://swiatecki.io/) |
