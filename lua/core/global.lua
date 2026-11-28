vim.g.mapleader = " " -- bind spacebar to leader key

-- Disable legacy SQL omnifunc mappings that override insert-mode arrow keys.
vim.g.omni_sql_no_default_maps = 1

vim.g.colors = {
  white = "#ffffff",
  bg = "#282c34",
  pink = "#ffc2c2",
  rose_beige = "#f5e0dc",
  gold = "#f9e2af",
  lavender = "#cba6f7",
  orange = "#FFB86C",
  brown = "#26231c",
}

vim.g.colors_transparent = {
  cursorline = "#1a2332",
  visual = "#3b4b68",
}

-- check leetcode.nvim arg option
vim.g.leetcode = vim.fn.argv(0, -1) == "leet"
vim.g.leetcode_lsp_off = vim.g.leetcode

-- Running inside Ghostty with its CLI reachable.
-- GHOSTTY_RESOURCES_DIR survives tmux, unlike TERM_PROGRAM.
vim.g.ghostty = vim.env.GHOSTTY_RESOURCES_DIR ~= nil and vim.fn.executable("ghostty") == 1

vim.g.sidekick_buf_filetype = "sidekick_terminal"
