#!/usr/bin/env bash
# PostToolUse hook: formats the Lua files an agent just edited with the repository's .stylua.toml.
# Shared by Claude Code (.claude/settings.json), which passes tool_input.file_path, and Codex (.codex/hooks.json),
# whose apply_patch passes the patch text in tool_input.command.
# Exit 2 sends stylua's parse errors back to the agent.
set -u

root=$(cd "$(dirname "$0")/../.." && pwd)
stylua="$HOME/.local/share/nvim/mason/bin/stylua"
input=$(cat)
cwd=$(jq -r '.cwd // empty' <<<"$input")

paths=$(jq -r '
  .tool_input.file_path // empty,
  (.tool_input.command // empty | strings | split("\n")[]
    | capture("^\\*\\*\\* (Add File|Update File|Move to): (?<path>.+)$")? | .path)
' <<<"$input")

status=0
while IFS= read -r path; do
  [ -n "$path" ] || continue
  case "$path" in
    /*) ;;
    *) path="${cwd:-$PWD}/$path" ;;
  esac
  case "$path" in
    "$root"/*.lua) ;;
    *) continue ;;
  esac
  [ -f "$path" ] || continue
  (cd "$root" && "$stylua" "$path") || status=2
done <<<"$paths"

exit "$status"
