return {
  {
    "sainnhe/sonokai",
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true
      vim.g.sonokai_transparent_background = 2 -- 1: 편집 영역에만 적용, 2: 더 넓은 요소들에 적용
      vim.g.sonokai_enable_italic = 1
      vim.g.sonokai_style = "shusia"
      vim.g.sonokai_diagnostic_text_highlight = 1
      vim.g.sonokai_diagnostic_line_highlight = 1
      vim.g.sonokai_diagnostic_virtual_text = 1
      vim.g.sonokai_better_performance = 1

      local custom_pink = "#ffc2c2"
      local shusia_purple = "#ab9df2"
      local shusia_red = "#f85e84"
      local shusia_orange = "#ef9062"
      local shusia_blue = "#7accd7"
      -- local shusia_yellow = "#e5c463"
      -- local shusia_green = "#9ecd6f"

      -- Override specific colors in the Sonokai palette
      -- Sonokai's color overrides must be set before loading the theme
      vim.g.sonokai_colors_override = {
        -- First value is hex color, second is terminal color
        green = { shusia_blue, "142" },
        blue = { custom_pink, "142" },

        purple = { shusia_red, "142" },
        red = { shusia_orange, "142" },
        orange = { shusia_purple, "142" },
      }

      vim.api.nvim_create_autocmd("VimEnter", {
        -- makes some UI's background transparent
        callback = function()
          -- 팝업 메뉴 관련 하이라이트 그룹 투명화
          vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE" })
          vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#3a3e56" }) -- 선택된 항목
          vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "NONE" })
          vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#4a4a4a" })

          -- 플로팅 윈도우 관련 하이라이트 그룹 투명화
          vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
          vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })

          -- LSP 진단 팝업 관련
          vim.api.nvim_set_hl(0, "LspFloatWinNormal", { bg = "NONE" })
          vim.api.nvim_set_hl(0, "LspFloatWinBorder", { bg = "NONE" })

          -- 자동 완성 메뉴 (nvim-cmp 사용 시)
          vim.api.nvim_set_hl(0, "CmpItemMenu", { bg = "NONE" })
          vim.api.nvim_set_hl(0, "CmpPmenu", { bg = "NONE" })
          vim.api.nvim_set_hl(0, "CmpDocumentation", { bg = "NONE" })
          vim.api.nvim_set_hl(0, "CmpDocumentationBorder", { bg = "NONE" })
        end,
      })

      vim.cmd.colorscheme("sonokai")
    end,
  },
}
