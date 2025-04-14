-- A plugin to manage notifications
return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  config = function()
    local notify = require("notify")

    notify.setup({
      fps = 60,
      max_width = 80,
      timeout = 2000,
      wrap = true,
      merge_duplicates = false,

      render = "wrapped-compact", -- default, minimal, simple, compact, wrapped-compact
      background_colour = "#000000",

      position = "top_right", -- top, top_right, top_left, bottom, bottom_left, bottom_right
      stages = "fade", -- fade, slide, fase_in_slide_out, static

      icons = {
        INFO = "󰋼",
        ERROR = "󰅙",
        WARN = "󰀦",
        DEBUG = "󰃤",
        TRACE = "󰥔",
      },
    })

    vim.keymap.set("n", "<leader>nc", function()
      notify.dismiss({ silent = true, pending = false })
    end, { noremap = true, silent = true, desc = "Clear all notifications" })
  end,
}
