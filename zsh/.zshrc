# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=6

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd.mm.yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

source ~/.zplug/init.zsh

# Load the oh-my-zsh's library.
zplug "zsh-users/zsh-history-substring-search"

# Make sure to use double quotes
zplug "zsh-users/zsh-syntax-highlighting"

# Fish-like auto suggestions
zplug "zsh-users/zsh-autosuggestions"

# Extra zsh completions
zplug "zsh-users/zsh-completions"

# For terminal tab gives a color based on commands that run there
zplug "bernardop/iterm-tab-color-oh-my-zsh"

# Better npm code completion
zplug "torifat/npms"


zplug "ytet5uy4/fzf-widgets"
if zplug check 'ytet5uy4/fzf-widgets'; then
    # Map widgets to key
    bindkey '^@'  fzf-select-widget
    bindkey '^@.' fzf-edit-dotfiles
    bindkey '^@c' fzf-change-directory
    bindkey '^@n' fzf-change-named-directory
    bindkey '^@f' fzf-edit-files
    bindkey '^@k' fzf-kill-processes
    bindkey '^@s' fzf-exec-ssh
    bindkey '^\'  fzf-change-recent-directory
    bindkey '^r'  fzf-insert-history
    bindkey '^xf' fzf-insert-files
    bindkey '^xd' fzf-insert-directory
    bindkey '^xn' fzf-insert-named-directory

    ## Git
    bindkey '^@g'  fzf-select-git-widget
    bindkey '^@ga' fzf-git-add-files
    bindkey '^@gc' fzf-git-change-repository

    # GitHub
    bindkey '^@h'  fzf-select-github-widget
    bindkey '^@hs' fzf-github-show-issue
    bindkey '^@hc' fzf-github-close-issue

    ## Docker
    bindkey '^@d'  fzf-select-docker-widget
    bindkey '^@dc' fzf-docker-remove-containers
    bindkey '^@di' fzf-docker-remove-images
    bindkey '^@dv' fzf-docker-remove-volumes

    # Start fzf in a tmux pane
    FZF_WIDGET_TMUX=1
fi

# Good aliases list and finder aliases
zplug "akash329d/zsh-alias-finder"

# adds fuzzy search to tab completion of z
zplug "changyuheng/fz", defer:1
zplug "rupa/z", use:z.sh


# Load the theme.
zplug "caiogondim/bullet-train.zsh", as:theme

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load --verbose

plugins=(
    1password
    asdf
    brew
    command-not-found
    docker
    docker-compose
    flutter
    gitfast
    helm
    iterm2
    jsontools
    kubectl
    macos
    node
    npm
    sudo

    ## My Settings
    snics-settings
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
