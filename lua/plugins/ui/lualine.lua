-- A plugin for customizing statusline of neovim
vim.pack.add({
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

vim.cmd.packadd("nvim-web-devicons")
vim.cmd.packadd("lualine.nvim")

local lualine = require("lualine")

-- configure lualine with modified theme
lualine.setup({
  options = {
    -- NOTE: catppuccin dependency
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
    lualine_x = { "filetype" },
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
    "quickfix",
    "nvim-dap-ui",
    "toggleterm",
    "Man",
  },
})
