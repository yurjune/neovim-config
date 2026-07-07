-- A plugin that expands the current window
return {
  "anuvyklack/windows.nvim",
  dependencies = {
    "anuvyklack/middleclass",
    "szw/vim-maximizer",
  },
  config = function()
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

    -- By vim-maximizer
    vim.keymap.set("n", "<leader>wm", "<Cmd>MaximizerToggle!<CR>", { desc = "Maximize window fully" })
  end,
}
