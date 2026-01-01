vim.pack.add({
  "https://github.com/szw/vim-maximizer",
})
vim.cmd.packadd("vim-maximizer")

vim.keymap.set("n", "<leader>wm", "<cmd>MaximizerToggle!<CR>", { desc = "Maximize window fully" })
