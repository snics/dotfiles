#!/bin/bash
set -e

TTYD_OPTS=(-W -p 7681 -t "titleFixed=snics/devenv-web" -t "fontSize=14")

case "${TTYD_MODE}" in
  terminal)
    exec ttyd "${TTYD_OPTS[@]}" zsh -l
    ;;
  tmux)
    exec ttyd "${TTYD_OPTS[@]}" tmux new-session -A -s main
    ;;
  nvim)
    exec ttyd "${TTYD_OPTS[@]}" nvim
    ;;
  *)
    # Custom: treat TTYD_MODE as the command itself
    exec ttyd "${TTYD_OPTS[@]}" ${TTYD_MODE}
    ;;
esac
