# Emacs keybindings
bindkey -e

# macOS Alt+C fix: Option+C produces 'ç' instead of \ec escape sequence.
# Bind the literal character to fzf's cd widget so Alt+C works as expected.
bindkey 'ç' fzf-cd-widget
