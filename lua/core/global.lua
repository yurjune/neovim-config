vim.g.mapleader = " " -- bind spacebar to leader key

-- Disable legacy SQL omnifunc mappings that override insert-mode arrow keys.
vim.g.omni_sql_no_default_maps = 1

vim.g.colors = {
  white = "#ffffff",
  bg = "#282c34",
  pink = "#ffc2c2",
  rose_beige = "#f5e0dc",
  gold = "#f9e2af",
}

vim.g.colors_transparent = {
  cursorline = "#1a2332",
}

-- check leetcode.nvim arg option
vim.g.leetcode = vim.fn.argv(0, -1) == "leet"
vim.g.leetcode_lsp_off = vim.g.leetcode

vim.g.sidekick_buf_filetype = "sidekick_terminal"
