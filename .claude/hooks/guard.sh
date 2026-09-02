#!/usr/bin/env bash
# PreToolUse guard for Bash calls.
# Receives the tool call as JSON on stdin. Exit 2 blocks the call and sends
# the stderr message back to Claude so it can choose another approach.

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
else
  # Fallback without jq: pull the command string out with sed.
  cmd=$(printf '%s' "$input" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')
fi

if printf '%s' "$cmd" | grep -Eq 'rm -rf +/( |$)|git push .*(--force|-f)( |$)|DROP TABLE'; then
  echo "Blocked by .claude/hooks/guard.sh: '$cmd' looks destructive. Ask the user to run it manually if it is really needed." >&2
  exit 2
fi

exit 0
