return {
  "anuvyklack/windows.nvim",
  dependencies = { "anuvyklack/middleclass" },
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
  end,
}
