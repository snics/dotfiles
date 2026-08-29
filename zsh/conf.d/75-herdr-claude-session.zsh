# The herdr server daemon was once started from inside a Claude Code session
# and therefore carries CLAUDE_CODE_CHILD_SESSION=1 in its environment. Every
# herdr pane shell inherits it, which makes any `claude` launched there think
# it is a nested child session and silently disable transcript saving.
# Drop the marker in herdr shells only, so legitimate nested Claude sessions
# elsewhere keep their intended behavior.
if [[ -n "$HERDR_ENV" ]]; then
  unset CLAUDE_CODE_CHILD_SESSION
fi
