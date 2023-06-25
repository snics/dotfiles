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

# Automatically switch versions of node by looking for a .nvmrc file in the path tree
zplug "aspirewit/zsh-nvm-auto-switch"

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

# Better Helm autosuggestions
zplug "downager/zsh-helmfile"
