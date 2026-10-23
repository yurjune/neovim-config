---
name: update-plugins
description: 사용자가 Neovim 플러그인 업데이트를 요청할 때 사용합니다.
---

# 플러그인 업데이트

- breaking 여부와 관계없이 전부 한 번에 업데이트하고, 검증하고, 한 커밋으로 묶는다.
- 마이그레이션이 커서 따로 다룰 플러그인만 빼서, 일괄 커밋 뒤에 플러그인별로 업데이트하고 커밋한다.
- 이 스킬은 `CLAUDE.md`의 headless 규칙과 커밋 전 확인 규칙의 예외다.
- 하네스가 검증하지 못하는 동작은 체크리스트로 사용자에게 넘긴다.
- Mason 패키지는 범위 밖이다.

## 단계

1. `git status --porcelain lazy-lock.json`이 비어 있지 않으면 멈추고 묻는다.
2. 하네스로 기준선을 기록한다.
3. 업데이트한다.
4. 업데이트된 플러그인을 분류한다.
5. 하네스를 다시 실행해 기준선 대비 새로 생긴 문제만 추린다.
6. 문제가 없어질 때까지 고치고 다시 검증한다.
   - 원인이 분명하면 spec을 마이그레이션한다.
   - 원인이 불분명하면 격리한다.
   - 따로 다룰 플러그인은 함께 바뀐 묶음과 함께 이전 커밋으로 되돌린다.
7. 일괄 커밋한다.
8. 따로 다룰 플러그인마다 바로 이어서 업데이트, 마이그레이션, 하네스 검증, 커밋을 한다.
9. 보고서를 작성하고 체크리스트를 넘긴다.

따로 다룰지는 판단하되, spec 여러 곳을 고쳐야 하거나 `branch` 변경처럼 대규모 재작성인 경우가 해당한다.
일괄 커밋 전에 대상과 근거를 보고하고 동의를 받는다.

## 업데이트

빌드 훅을 실행하고 lockfile을 갱신한다. 따로 다룰 플러그인은 `update <name>`으로 하나씩 업데이트한다.

```sh
nvim --headless "+Lazy! update" +qa
```

`:TSUpdate` 빌드 훅은 parser를 비동기로 설치하므로 `+qa`에 끊긴다. 설치가 끝날 때까지 기다려 다시 갱신한다.

```sh
nvim --headless "+lua require('nvim-treesitter').update():wait(300000)" +qa
```

## 분류

```sh
.agents/skills/update-plugins/scripts/triage.sh  # 기준 리비전, 기본값 HEAD
```

lockfile이 바뀐 플러그인마다 한 줄을 출력하고, breaking change 후보 커밋을 그 아래 들여써 붙인다.

```text
neotest  deadfb1..1c529a1  42 commits  spec:lua/plugins/debug/neotest.lua  changelog:CHANGELOG.md
  e372852 fix(subprocess): fully remove tree-sitter dependency (#606)
nvim-treesitter  28d480e..61df849  469 commits  spec:...  branch:master->main
smart-splits.nvim  32f6788..ea55335  78 commits  spec:...  version:v2.1.0->v3.0.0
csvview.nvim  added  spec:lua/plugins/etc/csvview.lua
```

- 후보 커밋은 `!:|breaking|deprecat|remov|renam` 필터라 무관한 커밋도 걸린다. 하나씩 판단한다.
- 후보가 있으면 `spec`의 파일이 그 옵션·명령·모듈을 쓰는지 grep한다. 필요하면 `changelog`의 파일을 diff로 본다.
- `branch` 변경과 `version`의 메이저 변경(`v0.x`→`v1.0` 포함)은 대규모 재작성 신호다.
  커밋 메시지는 필터에 걸리지 않을 수 있으므로, 후보가 없어도 README와 전체 로그를 보고 spec의 옵션·명령이 남아 있는지 확인한다.
- 그 밖에 후보가 없는 플러그인은 한 줄로 끝나므로 더 보지 않는다.
- 영향 없음, 검토, 마이그레이션 필요로 나눈다. 마이그레이션 대상이 여럿이면 플러그인별 서브에이전트로 조사한다.

## 하네스

```sh
VERIFY_OUT=<scratchpad>/baseline.json nvim --headless -c "luafile .agents/skills/update-plugins/scripts/verify.lua" 2><scratchpad>/verify.log
VERIFY_OUT=<scratchpad>/after.json VERIFY_BASELINE=<scratchpad>/baseline.json nvim --headless -c "luafile .agents/skills/update-plugins/scripts/verify.lua" 2><scratchpad>/verify.log
```

`scripts/verify.lua`는 문제를 단계별로 `issues`에 담아 JSON으로 쓴다.
`VERIFY_BASELINE`을 주면 기준선에 없던 문제만 `new`에 담고, 하나라도 있으면 0이 아닌 코드로 종료한다.
진행 단계를 stderr에 쓰므로, 멈추면 로그의 마지막 줄이 멈춘 단계다.
단순 headless 기동은 대부분의 플러그인을 로드하지 않으므로 다음을 직접 한다.

- 각 플러그인을 `pcall` 안에서 `require("lazy").load()`로 강제 로드한다. 모듈 이름 변경, 제거된 함수가 여기서 드러난다.
- `VeryLazy`를 직접 발생시킨다. lazy.nvim은 `UIEnter` 이후에만 발생시키는데, headless에는 오지 않는다.
- 커스텀 쿼리를 포함해 parser가 있는 언어의 Tree-sitter 쿼리를 모두 컴파일한다.
- 키맵이 부르는 사용자 명령(`<cmd>Foo`, `:Foo`)이 있는지 확인한다. 명령이 없어져도 로드는 성공하기 때문이다.
- `vim.notify`와 `:messages`를 수집하고, 종료 전 `vim.wait`로 늦게 오는 비동기 에러를 잡는다. startup 중 `setup()`이 예약한 경고도 잡도록 VimEnter에서 훅을 건다.

`setup()`은 모르는 옵션을 대부분 조용히 무시하므로, 옵션 이름 변경은 플러그인이 경고를 내야만 드러난다.
그래서 분류에서 메이저 변경을 따로 확인한다.
로드 이후의 동작은 검증하지 않는다. 로드 순서가 실제와 다르므로, 기준선에 없는 문제가 순서 탓으로 보이면 해당 플러그인만 실제 순서대로 확인한다.

## 체크리스트

하네스가 검증하지 못한 부분을 사용자가 직접 확인하도록 넘긴다. 바뀐 플러그인만 넣는다.

- 맨 위에 마이그레이션했거나 breaking change 후보가 있던 플러그인을 두고, 확인할 동작을 구체적으로 적는다.
- 그 아래에 렌더링, 키맵, filetype별 동작, UI 없이 setup을 건너뛰는 플러그인처럼 로드만으로 확인되지 않는 항목을 둔다.

```text
- [ ] conform: Lua 파일 저장 시 포맷되는지 (format_after_save로 마이그레이션)
- [ ] render-markdown: 제목 아이콘이 sign 열에 보이는지
- [ ] gitsigns: hunk 미리보기 키맵
```

## 플러그인 되돌리기

격리하거나 따로 다룰 플러그인을 뺄 때 쓴다.
업데이트 후 lockfile에는 새 커밋이 적혀 있으므로, 이전 커밋을 되돌려 쓴 뒤 restore한다.

```sh
old=$(git show HEAD:lazy-lock.json | jq -r --arg p "<name>" '.[$p].commit')
new=$(jq -r --arg p "<name>" '.[$p].commit' lazy-lock.json)
sed -i '' "s/$new/$old/" lazy-lock.json  # jq는 lockfile 전체를 다시 포맷한다
nvim --headless "+Lazy! restore <name>" +qa
```

격리할 때는 의심 플러그인이나 함께 바뀐 묶음을 되돌리고 다시 검증한다. 통과하면 그것이 원인이다.

## 커밋

- 커밋마다 그 시점의 lockfile 전체와 마이그레이션을 담는다.
- 따로 다룰 플러그인의 동의 외에는 확인 없이 커밋한다.

## 보고서

보고 내용을 `<scratchpad>/plugin-update-<YYYY-MM-DD>.md`에 Markdown으로 쓴다.
응답에는 결과 요약 몇 줄과 보고서의 전체 절대 경로만 적는다.

보고서는 아래 순서로 쓴다. 해당 내용이 없는 절도 "없음"으로 남긴다.

```markdown
# 플러그인 업데이트 <YYYY-MM-DD>

## 요약

업데이트한 플러그인 수, 커밋, 기준선 대비 새 문제 수

## 커밋

- 62f5e2a chore(plugins): update plugins

## 기준선 대비 결과

새로 생긴 문제마다 증상, 원인, 해결. 원인을 확정하지 못했으면 그렇게 적는다.
기준선부터 있던 문제는 목록만 적는다.

## 마이그레이션

플러그인별로 바꾼 파일과 이유

## 따로 다룬 플러그인

플러그인별 근거

## 업데이트 목록

| 플러그인 | 리비전 | 커밋 수 | 분류 | 비고 |
| --- | --- | --- | --- | --- |

분류는 영향 없음, 검토, 마이그레이션 중 하나이고, 비고에 후보 커밋을 판단한 근거를 적는다.

## 체크리스트

`체크리스트` 절의 형식
```

## 커밋 메시지

일반 규칙은 `CLAUDE.md`를 따르고, 이 스킬에서는 아래만 정한다.

- 본문의 upstream 변경에는 해당 upstream 커밋 해시를 붙이고, 커밋 제목에 PR 번호가 있으면 함께 적는다.

일괄 커밋은 제목을 고정한다. 마이그레이션이 없으면 본문을 생략하고, 있으면 플러그인별로 upstream 변경을 한 줄씩 적는다.

```text
chore(plugins): update plugins

Adapt specs to upstream breaking changes:
- conform: format_on_save renamed to format_after_save (upstream 1a2b3c4, #512)
- render-markdown: heading.icons moved under heading.sign (upstream 5d6e7f8)
```

따로 다룬 플러그인은 `chore(<plugin>)`으로 커밋하고, 본문에 upstream 변경과 그에 맞춘 설정 변경을 적는다.

```text
chore(treesitter): update to main branch

nvim-treesitter rewrote its API on main (upstream 61df849): the configs
module is gone, so highlight and indent are now enabled per filetype.
```
