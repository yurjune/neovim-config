---
name: check-keymap
description: Find where a key is already bound in this Neovim config, or verify a key is free. Use before adding or changing any keymap.
---

# Checking a keymap

`<leader>` is the spacebar. Bindings are spread across several places, so grepping `lua/core/keymaps.lua` alone proves
nothing.

## Search

```sh
grep -rn --include='*.lua' -F '<leader>xx' .  # exact lhs; catches vim.keymap.set and lazy.nvim keys specs
grep -rn --include='*.lua' -F '<leader>x' .   # prefixes too: which-key timeoutlen=1000 stalls the shorter mapping
grep -rn --include='*.lua' -E '"<[^"]*" *\.\.' .  # lhs built in a loop; the greps above report these free
```

`<leader>h3` is bound by `"<leader>h" .. level`, so match your key against the prefixes the third grep finds, then open
the owner for the loop bound.

Two things grep misses:

- Plugins that bind keys inside their own `opts` — a `keymaps` or `mappings` table — instead of `vim.keymap.set`. Check
  the spec of whichever plugin owns that filetype.
- Keys something else takes first — the OS, or a Neovim default (`:help default-mappings`) — and duplicates whose winner
  takes inference. Both live in [`keymaps.yaml`](../../ontology/keymaps.yaml); grep cannot reach either.

To confirm, ask the user to run `:verbose map <lhs>` in their running Neovim; it reports the winner and its source file.
Do not launch `nvim --headless` for this.

## When adding one

- Every mapping takes a `desc`; which-key renders it.
- Keep a plugin's mappings in its own spec, as `keys = {}` so they lazy-load it.
- Specify all modes it needs (`{ "n", "v" }`); a visual-mode gap is a common miss.
- Bind buffer-locally (`buffer = ev.buf`) when it only makes sense in one filetype.
