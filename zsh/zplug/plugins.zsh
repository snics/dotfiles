# load all of oh-my-zsh's plugins.

# Oh my zsh plugins
# -----------------

## Tools
zplug "plugins/1password", from:oh-my-zsh
zplug "plugins/command-not-found", from:oh-my-zsh
zplug "plugins/copyfile", from:oh-my-zsh
zplug "plugins/iterm2", from:oh-my-zsh
zplug "plugins/macos", from:oh-my-zsh
zplug "plugins/web-search", from:oh-my-zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/brew", from:oh-my-zsh

## Dev toolsets
zplug "plugins/podman", from:oh-my-zsh
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh
zplug "plugins/helm", from:oh-my-zsh
zplug "plugins/jsontools", from:oh-my-zsh
zplug "plugins/gitfast", from:oh-my-zsh
zplug "plugins/kubectl", from:oh-my-zsh
zplug "plugins/minikube", from:oh-my-zsh


## Languages
zplug "plugins/flutter", from:oh-my-zsh
zplug "plugins/node", from:oh-my-zsh
zplug "plugins/npm", from:oh-my-zsh
zplug "plugins/nvm", from:oh-my-zsh

# Zplug plugins
# -----------------

## Tools

### Load the oh-my-zsh's library.
zplug "zsh-users/zsh-history-substring-search"

### Make sure to use double quotes
zplug "zsh-users/zsh-syntax-highlighting"

### For terminal tab gives a color based on commands that run there
zplug "bernardop/iterm-tab-color-oh-my-zsh"

### Better npm code completion
zplug "torifat/npms"

### adds fuzzy search to tab completion of z
zplug "changyuheng/fz", defer:1
zplug "rupa/z", use:z.sh



## Dev toolsets

### Better Helm autosuggestions
zplug "downager/zsh-helmfile"

### docker-aliases
zplug "webyneter/docker-aliases", use:docker-aliases.plugin.zsh

### Some helpers for docker
zplug "unixorn/docker-helpers.zshplugin"

# Languages

### Adds fuzzy search to tab completion of go
zplug "wintermi/zsh-golang"

# Load it all up for suggestions and completions

### completions and suggestions
source "${0:h}/completions.zsh"
### fzf-widgets
source "${0:h}/fzf-widgets.zsh"
