-- A plugin to manipulate surrounding characters.
vim.pack.add({
  "https://github.com/echasnovski/mini.surround",
})
vim.cmd.packadd("mini.surround")

require("mini.surround").setup({
  mappings = {
    add = "Zsa", -- Add surrounding in Normal and Visual modes
    delete = "Zsd", -- Delete surrounding
    find = "Zsf",
    find_left = "ZsF",
    replace = "Zsr",
    highlight = "Zsh",
  },
})
