vim.g.colors = {
  bg = "#282c34",
  pink = "#ffc2c2",
  rose_beige = "#f5e0dc",
}

vim.g.colors_transparent = {
  -- cursorline = "#2a2a2a",
  -- cursorline = "#1a3a52",
  cursorline = "#1a2332",
}

-- check leetcode.nvim arg option
vim.g.leetcode = vim.fn.argv(0, -1) == "leet" and true or false
vim.g.leetcode_lsp_off = not vim.g.leetcode

vim.g.sidekick_buf_pattern = "term://*"

-- default providers
vim.g.loaded_node_provider = 1
vim.g.loaded_python3_provider = 1
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
