return {
  {
    "folke/tokyonight.nvim",
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      local bg = "#011628"
      local bg_dark = "#011423"
      local bg_highlight = "#143652"
      local bg_search = "#0A64AC"
      local bg_visual = "#275378"
      local fg = "#CBE0F0"
      local fg_dark = "#B4D0E9"
      local fg_gutter = "#627E97"
      local border = "#547998"
      local string_color = "#ffc2c2"
      local comment_color = "#bdfcc9"

      require("tokyonight").setup({
        style = "night",
        on_colors = function(colors)
          colors.bg = bg
          colors.bg_dark = bg_dark
          colors.bg_float = bg_dark
          colors.bg_highlight = bg_highlight
          colors.bg_popup = bg_dark
          colors.bg_search = bg_search
          colors.bg_sidebar = bg_dark
          colors.bg_statusline = bg_dark
          colors.bg_visual = bg_visual
          colors.border = border
          colors.fg = fg
          colors.fg_dark = fg_dark
          colors.fg_float = fg
          colors.fg_gutter = fg_gutter
          colors.fg_sidebar = fg_dark
        end,

        on_highlights = function(hl, c)
          -- 문자열 색상 설정
          hl.String = {
            fg = string_color,
          }

          -- 관련 문자열 요소들도 함께 변경할 수 있습니다
          hl.Character = {
            fg = string_color,
          }

          -- 주석 색상 설정
          hl.Comment = {
            fg = comment_color,
            -- 필요하다면 italic 스타일 추가 가능
            italic = true,
          }

          -- 문서 주석 (DocComment)도 같은 색상으로 설정
          hl.DocComment = {
            fg = comment_color,
            italic = true,
          }
        end,
      })

      -- load the colorscheme here
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
}
