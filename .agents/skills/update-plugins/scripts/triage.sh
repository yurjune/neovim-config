#!/usr/bin/env bash
# Summarize lazy-lock.json changes against a git revision (default HEAD).
# One header line per changed plugin; breaking-change candidates are indented below it.
set -euo pipefail

base=${1:-HEAD}
cd "$(git rev-parse --show-toplevel)"
lazy=${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy
pattern='!:|breaking|deprecat|remov|renam'

jq -rn --argjson old "$(git show "$base:lazy-lock.json")" --slurpfile new lazy-lock.json '
  $new[0] as $new
  | ([$old, $new] | add | keys[]) as $k
  | select($old[$k] != $new[$k])
  | [$k, $old[$k].commit // "-", $new[$k].commit // "-", $old[$k].branch // "-", $new[$k].branch // "-"]
  | @tsv' |
  while IFS=$'\t' read -r name old new old_branch new_branch; do
    # Specs reference a plugin by "<owner>/<name>", or by `name = "<name>"` when the repo name differs.
    escaped=${name//./\\.}
    spec=$(grep -rlE --include='*.lua' "/$escaped\"|name = \"$escaped\"" lua/plugins | paste -sd, - || true)
    if [[ $old == - ]]; then
      echo "$name  added  spec:${spec:--}"
      continue
    elif [[ $new == - ]]; then
      echo "$name  removed"
      continue
    fi

    dir=$lazy/$name
    count=$(git -C "$dir" rev-list --count "$old..$new" 2>/dev/null || echo "?")
    line="$name  ${old:0:7}..${new:0:7}  $count commits  spec:${spec:--}"
    [[ $old_branch != "$new_branch" ]] && line+="  branch:$old_branch->$new_branch"
    changelog=$(git -C "$dir" diff --name-only "$old" "$new" 2>/dev/null | grep -iE '(^|/)(changelog|news)' | paste -sd, - || true)
    [[ -n $changelog ]] && line+="  changelog:$changelog"
    echo "$line"

    git -C "$dir" log --format='  %h %s' -i -E --grep="$pattern" "$old..$new" 2>/dev/null || true
  done
