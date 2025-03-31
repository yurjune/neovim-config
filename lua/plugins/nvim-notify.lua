return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  config = function()
    local notify = require("notify")

    -- 플러그인을 활성화하려면 주석 해제
    -- vim.notify = notify

    notify.setup({
      merge_duplicates = false,
      fps = 60,
      max_width = 80,
      timeout = 3000,

      -- default, minimal, simple, compact, wrapped-compact
      render = "default",

      background_colour = "#000000",

      -- 알림 표시 위치 ('top_right', 'top', 'top_left', 'bottom_left', 'bottom', 'bottom_right')
      position = "top_right",

      -- 알림 애니메이션 스타일 ('fade', 'slide', 'fade_in_slide_out', 'static')
      stages = "fade_in_slide_out",

      icons = {
        ERROR = "󰅙",
        WARN = "󰀦",
        INFO = "󰋼",
        DEBUG = "󰃤",
        TRACE = "󰥔",
      },
    })

    vim.keymap.set("n", "<leader>nc", function()
      notify.dismiss({ silent = true, pending = false })
    end, { noremap = true, silent = true, desc = "Clear all notifications" })
  end,
}
