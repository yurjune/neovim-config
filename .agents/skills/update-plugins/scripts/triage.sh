#!/usr/bin/env bash
# git 리비전(기본값 HEAD) 대비 lazy-lock.json 변경을 요약한다.
# 바뀐 플러그인마다 한 줄을 쓰고, breaking change 후보 커밋을 그 아래 들여써 붙인다.
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
    # spec은 플러그인을 "<owner>/<name>"으로, 레포 이름과 다르면 `name = "<name>"`으로 가리킨다.
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
    old_tag=$(git -C "$dir" describe --tags --abbrev=0 "$old" 2>/dev/null || true)
    new_tag=$(git -C "$dir" describe --tags --abbrev=0 "$new" 2>/dev/null || true)
    [[ -n $new_tag && $old_tag != "$new_tag" ]] && line+="  version:${old_tag:--}->$new_tag"
    changelog=$(git -C "$dir" diff --name-only "$old" "$new" 2>/dev/null | grep -iE '(^|/)(changelog|news)' | paste -sd, - || true)
    [[ -n $changelog ]] && line+="  changelog:$changelog"
    echo "$line"

    git -C "$dir" log --format='  %h %s' -i -E --grep="$pattern" "$old..$new" 2>/dev/null || true
  done
