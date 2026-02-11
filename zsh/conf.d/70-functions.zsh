# Auto-source all function files and register embedded completions
for fn in ~/.dotfiles/zsh/functions/*.zsh(N); do
  source "$fn"
  local fname="${fn:t:r}"
  (( $+functions[_${fname}] )) && compdef "_${fname}" "${fname}"
done
unset fn fname
