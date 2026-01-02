--- All about "surroundings": parentheses, brackets, quotes, XML tags, and more
vim.pack.add({
  "https://github.com/kylechui/nvim-surround",
})
vim.cmd.packadd("nvim-surround")

require("nvim-surround").setup({})
