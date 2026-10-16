# Sidekick

Sidekick runs AI CLI tools in a tmux-backed split on the right.
[`sidekick.lua`](sidekick.lua) configures the Sidekick plugin, CLI tools, and its keymaps.

## Window and terminal behavior

The split width comes from [`ui.layout`](../../ui/layout.lua).
Opening or closing a Sidekick split manually equalizes the other windows on the next event loop.
This must remain scheduled because Sidekick sets its fixed width after opening the split.

Claude and Codex disable their alternate screens so their output remains in tmux scrollback.
`nav_down` is disabled because Ghostty sends Shift-Enter as `\n`, which Neovim interprets as `<C-j>`.

## Cross-module contracts

`vim.g.sidekick_buf_filetype` in [`core.global`](../../core/global.lua) identifies Sidekick terminal buffers.
The following integrations depend on that value remaining aligned with Sidekick's buffer filetype:

- [`auto-session.lua`](../workflow/auto-session.lua) closes Sidekick windows before automatic session saves.
  Restoring one would otherwise create another tmux session.
  Explicit saves preserve Sidekick windows.
- [`switch-input-source`](../../etc/switch-input-source/README.md) uses `BufLeave` and `BufEnter` for Sidekick input-source transitions.
  Sidekick is a terminal buffer, so normal insert-mode events are not the appropriate boundary.
