; extends

;; Inject SQL syntax highlighting into raw string literals containing SQL keywords
((raw_string_literal
  (string_content) @injection.content)
 (#lua-match? @injection.content "[Ss][Ee][Ll][Ee][Cc][Tt]")
 (#set! injection.language "sql"))

((raw_string_literal
  (string_content) @injection.content)
 (#lua-match? @injection.content "[Ii][Nn][Ss][Ee][Rr][Tt]")
 (#set! injection.language "sql"))

((raw_string_literal
  (string_content) @injection.content)
 (#lua-match? @injection.content "[Uu][Pp][Dd][Aa][Tt][Ee]")
 (#set! injection.language "sql"))

((raw_string_literal
  (string_content) @injection.content)
 (#lua-match? @injection.content "[Dd][Ee][Ll][Ee][Tt][Ee]")
 (#set! injection.language "sql"))

((raw_string_literal
  (string_content) @injection.content)
 (#lua-match? @injection.content "[Ww][Ii][Tt][Hh]")
 (#set! injection.language "sql"))

((raw_string_literal
  (string_content) @injection.content)
 (#lua-match? @injection.content "[Cc][Rr][Ee][Aa][Tt][Ee]")
 (#set! injection.language "sql"))
