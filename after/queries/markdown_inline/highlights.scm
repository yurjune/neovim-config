; extends

; Keep brackets visible in shortcut links, including standalone [text].
(shortcut_link
  "[" @markup.link
  (#set! conceal "[")
  (#set! priority 101))

(shortcut_link
  "]" @markup.link
  (#set! conceal "]")
  (#set! priority 101))
