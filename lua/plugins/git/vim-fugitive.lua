-- A plugin that provides Git commands inside Vim.
vim.pack.add({
  "https://github.com/tpope/vim-fugitive",
})
vim.cmd.packadd("vim-fugitive")

vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit<CR>", { desc = "Git diff" })
vim.keymap.set("n", "<leader>gD", "<cmd>Gvdiffsplit HEAD~1<CR>", { desc = "Git diff HEAD~1" })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
