vim.pack.add({ "https://github.com/rcarriga/nvim-notify" })
vim.cmd.packadd("nvim-notify")

local notify = require("notify")

notify.setup({
  background_colour = vim.g.colors.bg,
  fps = 60,
  max_width = 50,
  minimum_width = 50,
  max_height = 24,
  timeout = 500,
  merge_duplicates = false,

  render = "wrapped-compact", -- default, minimal, simple, compact, wrapped-compact
  stages = "fade", -- fade, slide, fade_in_slide_out, static
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
