vim.pack.add({
  "https://github.com/anuvyklack/windows.nvim",
  "https://github.com/anuvyklack/middleclass",
})
vim.cmd.packadd("windows.nvim")
vim.cmd.packadd("middleclass")

require("windows").setup({
  autowidth = {
    enable = false,
  },
  ignore = {
    buftype = { "quickfix" },
    -- filetype = { "NvimTree" },
  },
})

vim.keymap.set("n", "<leader>wn", "<Cmd>WindowsMaximize<CR>", { desc = "Maximize window limitly" })
