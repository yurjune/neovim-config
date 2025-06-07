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
      merge_duplicates = false,

      render = "wrapped-compact", -- default, minimal, simple, compact, wrapped-compact
      background_colour = vim.g.colors.bg,

      stages = "fade_in_slide_out", -- fade, slide, fade_in_slide_out, static
      top_down = true, -- If true, notification position will be top

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
