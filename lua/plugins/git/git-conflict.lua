-- A plugin to manage Git conflicts in Neovim
vim.pack.add({
  "https://github.com/akinsho/git-conflict.nvim",
})
vim.cmd.packadd("git-conflict.nvim")

require("git-conflict").setup({
  default_mappings = true,
  -- default_mappings = {
  --   ours = "o",
  --   theirs = "t",
  --   none = "0",
  --   both = "b",
  --   next = "n",
  --   prev = "p",
  -- },
  default_highlights = true,
  disable_diagnostics = false,
  debug = false,
  list_opener = "copen",
  highlights = {
    incoming = "DiffAdd",
    current = "DiffText",
  },
})

vim.keymap.set("n", "<leader>gc", "<cmd>GitConflictListQf<CR>", { desc = "Git conflicts list" })
