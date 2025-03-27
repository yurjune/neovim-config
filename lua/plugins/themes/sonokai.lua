return {
  {
    "sainnhe/sonokai",
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true
      vim.g.sonokai_transparent_background = 1
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

      vim.cmd.colorscheme("sonokai")
    end,
  },
}
