# Auto-source all function files
for fn in ~/.dotfiles/zsh/functions/*.zsh(N); do
  source "$fn"
done
unset fn
