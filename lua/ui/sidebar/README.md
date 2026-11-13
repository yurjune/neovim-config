# Sidebar

The sidebar is a fixed-width split on the left of the current tab. It has two modes:

- **blank** keeps an empty contextual area at the configured sidebar width.
- **tree** renders the current working directory with the `tree` CLI and temporarily uses the tree width from
  [`ui.layout`](../layout.lua).

[`init.lua`](init.lua) owns the split and exposes operations for opening, closing, focusing, and toggling the sidebar
and tree. [`files.lua`](files.lua) owns file discovery, tree order, and adjacent-file lookup. [`tree.lua`](tree.lua)
owns rendering, cursor navigation, and current-file tracking.

## State and focus

Three globals preserve the intended UI state across session restoration:

- `vim.g.SidebarWidth` is the preferred width for blank mode.
- `vim.g.SidebarMode` records `blank` or `tree`.
- `vim.g.SidebarOpen` records whether the split should exist.

Tree mode remembers the current editor window as its target. Selected files open there, and closing the tree returns
focus there. It also follows `BufEnter` to highlight the current file when it belongs to the rendered working directory.
The shared file snapshot indexes every path by its absolute form, so that lookup stays a table hit however large the
tree is.

## Interaction contracts

`<CR>` opens the selected file in the tree's saved target window and moves focus there. `<Tab>` opens it in that window
while keeping focus in the tree. `<Esc>` returns to the target window and switches back to blank mode. If the saved
target window has been closed, opening a file is cancelled with a warning rather than choosing a different window.

`g1` / `g2` open the previous / next file in tree order, skipping directories and missing files without wrapping at
either end. In an editor window, navigation starts from the current file; in the tree, it starts from the cursor and
keeps focus there. With a visible tree, files open in its saved target window. With the tree closed or in blank mode,
navigation uses the current working directory and opens files in the current editor window without opening the tree.
Navigation does nothing when the current editor file is absent from the file snapshot.

## Shared file snapshot

File discovery is independent of sidebar buffers and windows so that navigation does not require rendering a tree.
Both navigation and rendering use the same discovery and ordering logic; a separate alphabetical file sort would drift
from the CLI's directory grouping, compression, and filtering.

The first navigation without a visible tree creates a snapshot, reused while the working directory and tree options
match. Closing the tree or returning to blank mode discards only its view state. Opening or refreshing the tree rebuilds
the shared snapshot; a visible tree navigates its displayed snapshot so file order stays aligned with the screen.

`<leader>pp` and file operations in [Oil](../../plugins/navigation/oil.lua) invalidate the cached snapshot even when the
tree is closed. Without a visible tree, the next navigation rebuilds it lazily. For external file changes, use
`<leader>pp` or reopen the tree to include new or renamed files; deleted files are skipped during navigation.

`files.lua` processes fd's file list with `tree --fromfile -C -f`: colour marks directories and `-f` prints each entry's
full path. Each line is split into the path it points to and the name shown in its place, so the cursor row always
indexes its own path. Replacing `-f` would break that, since nothing else in the output identifies the entry.

## Tree rendering and visibility

Rendering and file navigation require the external `fd` and `tree` executables. fd enumerates hidden entries and applies
the shared [file visibility policy](../../etc/file-visibility/README.md), allowing negated rules to reveal selected
dotfiles while ignoring project ignore files. tree renders the filtered list, preserving empty directories and symlink
targets.

## Width and window integration

Widths come from [`ui.layout`](../layout.lua). `winfixwidth` preserves the sidebar width, while `wincmd =` manually
equalizes the remaining windows after the sidebar opens, resizes, or closes.

[`auto-session.lua`](../../plugins/workflow/auto-session.lua) calls `restore` after restoring a session and `open` when
no session is restored. The exported `sidebar` filetype lets [`winbar.lua`](../winbar.lua) simplify its display and
[`windows.lua`](../../plugins/ui/windows.lua) exclude it from automatic width handling.
