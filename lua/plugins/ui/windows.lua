return {
  "anuvyklack/windows.nvim",
  dependencies = {
    "anuvyklack/middleclass",
  },
  enabled = true,
  config = function()
    vim.o.winwidth = 1
    vim.o.winminwidth = 1

    require("windows").setup({
      animation = {
        enable = false,
      },
      autowidth = {
        enable = false,
      },
      ignore = {
        filetype = {
          "sidekick_terminal",
          require("ui.sidebar").filetype,
        },
      },
    })

    vim.keymap.set("n", "<leader>wm", "<cmd>WindowsMaximize<CR>", {
      desc = "Toggle maximize window",
    })
  end,
}
