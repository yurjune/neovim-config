vim.pack.add({
  "https://github.com/catppuccin/nvim",
})
vim.cmd.packadd("nvim")

require("catppuccin").setup({
  transparent_background = true,
  flavour = "mocha",
  styles = {
    keywords = { "bold" },
    functions = { "italic" },
  },
  float = {
    transparent = true, -- -- enable transparent floating windows
    -- use solid styling for floating windows, see |winborder|
    -- e.g. if true, telecope window title becomes solid style
    solid = true,
  },
  lsp_styles = {
    virtual_text = {
      errors = { "italic", "bold", "undercurl" },
      warnings = { "italic", "bold", "undercurl" },
      information = { "italic", "bold" },
      hints = { "italic", "bold" },
      ok = { "italic", "bold" },
    },
    underlines = {
      errors = { "undercurl" },
      warnings = { "undercurl" },
      information = { "undercurl" },
      hints = { "undercurl" },
      ok = { "undercurl" },
    },
    inlay_hints = {
      background = true,
    },
  },
  default_integrations = true,
  auto_integrations = false,
  integrations = {
    alpha = true,
    -- bufferline: configured in bufferline.lua
    cmp = true, -- nvim-cmp
    dap = true, -- nvim-dap
    dap_ui = true,
    gitsigns = true,
    illuminate = { -- vim-illuminate
      enabled = true,
      lsp = false,
    },
    indent_blankline = {
      enabled = true,
      scope_color = "yellow", -- catppuccin color (eg. `lavender`) Default: text
      colored_indent_levels = false,
    },
    -- lualine: configured in lualine.lua
    markview = true,
    mason = true,
    navic = { -- nvim-navic
      enabled = true,
    },
    neotest = true,
    noice = true,
    notify = true, -- nvim-notify
    nvim_surround = true,
    nvimtree = true,
    telescope = {
      enabled = true,
    },
    treesitter_context = true,
    ufo = true, -- nvim-ufo
    which_key = true,
  },
  color_overrides = {
    mocha = {},
  },
  custom_highlights = function(colors)
    return {
      String = {
        fg = colors.sapphire,
      },
      LineNr = {
        fg = colors.overlay0,
      },

      Search = {
        fg = colors.mantle,
        bg = colors.rosewater,
      },
      CurSearch = {
        fg = colors.mantle,
        bg = colors.yellow,
      },
      IncSearch = {
        fg = colors.mantle,
        bg = colors.rosewater,
      },

      -- -- for neovide
      -- Normal = { -- current window
      --   bg = vim.g.colors.bg,
      -- },
      -- NormalNC = { -- not current window,
      --   bg = vim.g.colors.bg,
      -- },
      -- -- for leetcode.nvim
      -- NormalSB = { -- status bar
      --   bg = vim.g.colors.bg,
      -- },

      PanelHeading = {
        fg = colors.lavender,
        bg = colors.none,
        style = { "bold", "italic" },
      },
      FloatBorder = {
        fg = colors.yellow,
        bg = colors.none,
      },
      FloatTitle = {
        fg = colors.lavender,
        bg = colors.none,
      },
      PmenuThumb = { -- scrollbar in popup menu
        bg = colors.yellow,
      },
      PmenuSel = { -- selected item in popup menu
        bg = vim.g.colors_transparent.cursorline,
      },

      CmpBorder = {
        fg = colors.yellow,
      },

      -- Telescope
      TelescopeSelection = {
        fg = colors.yellow,
        bg = colors.none,
      },
      TelescopeSelectionCaret = {
        bg = colors.none,
      },
      TelescopeMatching = {},

      -- NvimTree
      NvimTreeCursorLine = {
        fg = colors.yellow,
        bg = colors.none,
      },
      NvimTreeFolderName = {
        fg = colors.lavender,
      },
      NvimTreeOpenedFolderName = {
        fg = colors.lavender,
      },
      NvimTreeOpenedFolderIcon = {
        fg = colors.lavender,
      },
      NvimTreeEmptyFolderName = {
        fg = colors.lavender,
      },
      NvimTreeStatusLineNC = {
        bg = colors.none,
      },

      GitSignsCurrentLineBlame = {
        fg = colors.overlay1,
        italic = true,
      },
    }
  end,
})

vim.cmd.colorscheme("catppuccin")
