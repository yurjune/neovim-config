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
        filetype = { "NvimTree" },
      },
    })

    vim.keymap.set("n", "<leader>wm", "<Cmd>WindowsMaximize<CR>", { desc = "Maximize Window" })
  end,
}
