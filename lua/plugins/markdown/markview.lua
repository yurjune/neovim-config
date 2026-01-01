vim.pack.add({
  "https://github.com/OXY2DEV/markview.nvim",
})
vim.cmd.packadd("markview.nvim")

local markview = require("markview")
markview.setup({})

vim.keymap.set("n", "<leader>mt", "<cmd>Markview toggle<cr>", { desc = "Toggle markdown preview" })
