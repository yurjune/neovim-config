-- A plugin that helps you remember your Neovim keymaps
vim.pack.add({ "https://github.com/folke/which-key.nvim" })

vim.o.timeout = true
vim.o.timeoutlen = 1000

vim.cmd.packadd("which-key.nvim")

require("which-key").setup({})
