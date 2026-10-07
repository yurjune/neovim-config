; Neovim 기본 Markdown injection 쿼리를 복사하되, pipe_table_cell만 제외한다.
;
; 기본 쿼리는 표의 모든 셀마다 별도의 markdown_inline 파서를 생성한다.
; 셀이 많은 표에서는 파서 수가 수백 개로 늘어나며, vim-smoothie가
; Ctrl-D/U 애니메이션의 중간 프레임을 그릴 때 큰 스크롤 지연을 일으킨다.
;
; 이 override는 표 셀의 중첩 파싱만 제거한다. 일반 Markdown 문법과
; 코드 블록, HTML, YAML/TOML frontmatter의 injection은 그대로 유지된다.
;
; Trade-off:
; - 표 셀 안의 굵게, 인라인 코드, 링크 등에 Tree-sitter 색상이 적용되지 않는다.
; - 파일 내용, 편집, table-nvim, Obsidian의 Markdown 렌더링에는 영향이 없다.
; - 기본 injections.scm 전체를 덮어쓰므로 Neovim이 새 injection을 추가하면
;   자동으로 반영되지 않는다. Neovim 업데이트 후 필요하면 기본 쿼리와 비교한다.

(fenced_code_block
  (info_string
    (language) @injection.language)
  (code_fence_content) @injection.content)

((html_block) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#set! injection.language "yaml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((plus_metadata) @injection.content
  (#set! injection.language "toml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((inline) @injection.content
  (#set! injection.language "markdown_inline"))
