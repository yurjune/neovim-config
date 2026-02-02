-- A plugin that provides Git commands inside Vim.
return {
  "tpope/vim-fugitive",
  event = "VeryLazy",
  config = function()
    vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit<CR>", { desc = "Git diff" })
    vim.keymap.set("n", "<leader>gD", "<cmd>Gvdiffsplit HEAD~1<CR>", { desc = "Git diff HEAD~1" })
    vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
  end,
}
