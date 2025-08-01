-- A plugin for customizing statusline of neovim
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count
    local codecompanion_lualine = require("modules.codecompanion_lualine")

    -- configure lualine with modified theme
    lualine.setup({
      options = {
        theme = "catppuccin",
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false, -- If true, one lualine for all windows
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          {
            "filename",
            path = 1, -- If 1, relative path is shown
            shorting_target = 40, -- 경로가 길 경우 줄이는 기준 길이
          },
        },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          { "filetype" },
        },
        lualine_y = { "location" },
        lualine_z = { "progress" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = {
        "nvim-tree",
        "avante",
        "quickfix",
        "nvim-dap-ui",
        "toggleterm",
        "Man",
        {
          filetypes = { "codecompanion" },
          sections = {
            lualine_a = { "mode" },
            lualine_b = { codecompanion_lualine.get_adapter_name },
            lualine_c = { codecompanion_lualine.get_current_model_name },
            lualine_x = {
              {
                codecompanion_lualine,
                color = { fg = "#ff9e64" },
              },
            },
            lualine_y = { "location" },
            lualine_z = { "progress" },
          },
          inactive_sections = {
            lualine_b = { codecompanion_lualine.get_adapter_name },
          },
        },
      },
    })
  end,
}
