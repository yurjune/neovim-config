# Sidebar

The sidebar is a fixed-width split on the left of the current tab.
It has two modes:

- **blank** keeps an empty contextual area at the configured sidebar width.
- **tree** renders the current working directory with the `tree` CLI and temporarily uses the tree width from [`ui.layout`](../layout.lua).

[`init.lua`](init.lua) owns the split and exposes operations for opening, closing, focusing, and toggling the sidebar and tree.
[`tree.lua`](tree.lua) owns rendering, navigation, and current-file tracking.

## State and focus

Three globals preserve the intended UI state across session restoration:

- `vim.g.SidebarWidth` is the preferred width for blank mode.
- `vim.g.SidebarMode` records `blank` or `tree`.
- `vim.g.SidebarOpen` records whether the split should exist.

Tree mode remembers the current editor window as its target.
Selected files open there, and closing the tree returns focus there.
It also follows `BufEnter` to highlight the current file when it belongs to the rendered working directory.

## Interaction contracts

`<CR>` opens the selected file in the tree's saved target window and moves focus there. `<Tab>` opens it in that window while keeping focus in the tree. `<Esc>` returns to the target window and switches back to blank mode.
If the saved target window has been closed, opening a file is cancelled with a warning rather than choosing a different window.

`tree.lua` generates a coloured display and a plain path list with separate `tree` calls.
Their rows must remain aligned: the cursor row in the display indexes the corresponding path in the plain list.
Any change to either command's output options must preserve that correspondence.

## Tree rendering and visibility

Tree mode requires the external `tree` executable.
It enumerates hidden entries and applies the shared [file visibility policy](../../etc/file-visibility/README.md) with `tree --gitfile`,
allowing negated rules to reveal selected dotfiles.

## Width and window integration

Widths come from [`ui.layout`](../layout.lua).
`winfixwidth` preserves the sidebar width, while `wincmd =` manually equalizes the remaining windows after the sidebar opens, resizes, or closes.

[`auto-session.lua`](../../plugins/workflow/auto-session.lua) calls `restore` after restoring a session and `open` when no session is restored.
The exported `sidebar` filetype lets [`winbar.lua`](../winbar.lua) simplify its display and [`windows.lua`](../../plugins/ui/windows.lua) exclude it from automatic width handling.
