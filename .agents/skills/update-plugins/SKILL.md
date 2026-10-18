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
3. 업데이트한다. 빌드 훅을 실행하고 lockfile을 갱신한다.

   ```sh
   nvim --headless "+Lazy! update" +qa
   ```

4. 업데이트된 플러그인을 분류한다.
5. 하네스를 다시 실행해 기준선 대비 새로 생긴 문제만 추린다.
6. 문제가 없어질 때까지 고치고 다시 검증한다.
   - 원인이 분명하면 spec을 마이그레이션한다.
   - 원인이 불분명하면 격리한다.
   - 따로 다룰 플러그인은 함께 바뀐 묶음과 함께 이전 커밋으로 되돌린다.
7. 일괄 커밋한다.
8. 따로 다룰 플러그인마다 바로 이어서 업데이트, 마이그레이션, 하네스 검증, 커밋을 한다.

   ```sh
   nvim --headless "+Lazy! update <name>" +qa
   ```

9. 보고하고 체크리스트를 넘긴다.

따로 다룰지는 판단하되, spec 여러 곳을 고쳐야 하거나 `branch` 변경처럼 대규모 재작성인 경우가 해당한다.
일괄 커밋 전에 대상과 근거를 보고하고 동의를 받는다.

## 분류

```sh
.agents/skills/update-plugins/scripts/triage.sh  # 기준 리비전, 기본값 HEAD
```

lockfile이 바뀐 플러그인마다 한 줄을 출력하고, breaking change 후보 커밋을 그 아래 들여써 붙인다.

```text
neotest  deadfb1..1c529a1  42 commits  spec:lua/plugins/debug/neotest.lua  changelog:CHANGELOG.md
  e372852 fix(subprocess): fully remove tree-sitter dependency (#606)
nvim-treesitter  28d480e..61df849  469 commits  spec:...  branch:master->main
octo.nvim  added  spec:lua/plugins/git/octo.lua
```

- 후보 커밋은 `!:|breaking|deprecat|remov|renam` 필터라 무관한 커밋도 걸린다. 하나씩 판단한다.
- 후보가 없는 플러그인은 한 줄로 끝나므로 더 보지 않는다.
- 후보가 있으면 `spec`의 파일이 그 옵션·명령·모듈을 쓰는지 grep한다. 필요하면 `changelog`의 파일을 diff로 본다.
- `branch` 변경은 대규모 재작성 신호다.
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

- 각 플러그인을 `pcall` 안에서 `require("lazy").load()`로 강제 로드한다. `setup()` 옵션 변경, 모듈 이름 변경, 제거된 함수가 여기서 드러난다.
- `VeryLazy`를 직접 발생시킨다. lazy.nvim은 `UIEnter` 이후에만 발생시키는데, headless에는 오지 않는다.
- 커스텀 쿼리를 포함해 parser가 있는 언어의 Tree-sitter 쿼리를 모두 컴파일한다.
- `vim.notify`와 `:messages`를 수집하고, 종료 전 `vim.wait`로 늦게 오는 비동기 에러를 잡는다.

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

## 보고와 커밋

- 커밋마다 그 시점의 lockfile 전체와 마이그레이션을 담는다.
- 따로 다룰 플러그인의 동의 외에는 확인 없이 커밋한다.
- 보고: 분류별 업데이트 목록, 마이그레이션 내용, 따로 다룬 플러그인과 근거, 기준선 대비 결과, 커밋 목록, 체크리스트

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
