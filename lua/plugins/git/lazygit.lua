-- A plugin that provides a Git TUI interface.
-- need to install lazygit: brew install jesseduffield/lazygit/lazygit
vim.pack.add({
  "https://github.com/kdheepak/lazygit.nvim",
  "https://github.com/nvim-lua/plenary.nvim", -- optional for floating window border decoration
})
vim.cmd.packadd("lazygit.nvim")
vim.cmd.packadd("plenary.nvim")

vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "Open lazy git" })
