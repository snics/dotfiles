completions_files=(${0:h}/completion/*.zsh)

for file in ${completions_files[@]}; do
  source $file
done

# Fish-like auto suggestions
zplug "zsh-users/zsh-autosuggestions"

# Extra zsh completions
zplug "zsh-users/zsh-completions"

#Replace zsh's default completion selection menu with fzf!
zplug "Aloxaf/fzf-tab"


# Sets the command to use for fzf-tab to 'fzf'.
zstyle ':completion:*:fzf-tab:*' command 'fzf'

# Limits the number of error messages output by the completion function to 1
zstyle ':completion:*' max-errors 1 numeric

# Defines the default completer for fzf-tab.
# _fzf_tab_try_custom_completion is a function that tries to run a custom completion if possible.
# If custom completion cannot be performed, default completion is used.
zstyle ':completion:*:complete:*' fzf-completer _fzf_tab_try_custom_completion

# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always --icons $realpath'


zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes


zstyle ':completion:*' insert-tab false
