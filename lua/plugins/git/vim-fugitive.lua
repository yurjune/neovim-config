-- A plugin that provides Git commands inside Vim.
return {
  "tpope/vim-fugitive",
  cmd = "Git",
  keys = {
    { "<leader>gb", "<cmd>Git blame --date='format:%Y-%m-%d %H:%M'<CR>", desc = "Git blame" },
  },
}
