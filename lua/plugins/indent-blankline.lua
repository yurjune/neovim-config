-- This plugin adds indentation guides to Neovim
return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPre", "BufNewFile" },
  main = "ibl",
  config = function()
    local ibl = require("ibl")
    local hooks = require("ibl.hooks")

    local highlight = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowBlue",
      "RainbowOrange",
      "RainbowGreen",
      "RainbowViolet",
      "RainbowCyan",
    }
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
      vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
      vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
      vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
      vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
      vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
    end)
    ibl.setup({
      enabled = true,
      debounce = 100,
      indent = {
        char = "¦",
        -- char = "│",
        -- highlight = highlight,
        smart_indent_cap = true, -- 과도한 들여쓰기 수준에서 시각적 혼란을 감소
        repeat_linebreak = true, -- 줄 바꿈 시 들여쓰기 표시를 반복할지 여부를 결정
      },
      scope = {
        show_start = false, -- 현재 스코프에 대한 밑줄 표시 여부
        show_exact_scope = false,
      },
    })
  end,
}
