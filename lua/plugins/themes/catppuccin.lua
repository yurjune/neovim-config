return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      transparent_background = true,
      flavour = "mocha",
      styles = {
        keywords = { "bold" },
        functions = { "italic" },
      },
      integrations = {
        alpha = true,
        cmp = true, -- nvim-cmp
        copilot_vim = true,
        dap = true, -- nvim-dap
        diffview = true,
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
        lsp_trouble = true, -- trouble.nvim
        mason = true,
        native_lsp = {
          enabled = true,
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
        navic = { -- nvim-navic
          enabled = true,
        },
        neogit = true,
        neotest = true,
        noice = true,
        notify = true, -- nvim-notify
        nvim_surround = true,
        nvimtree = true,
        render_markdown = true,
        telescope = { style = nil },
        treesitter = true, -- nvim-treesitter
        treesitter_context = true,
        ufo = true, -- nvim-ufo
        which_key = true,
      },
      color_overrides = {
        mocha = {},
      },
      custom_highlights = function(colors)
        return {
          String = { fg = colors.sapphire },
          CursorLine = { bg = colors.surface0 },
          CursorLineNr = { fg = vim.g.colors.rose_beige },
          LineNr = { fg = colors.overlay0 },

          -- for neovide
          Normal = { bg = vim.g.colors.bg },
          NormalNC = { bg = vim.g.colors.bg },
          -- for leetcode.nvim
          NormalSB = { bg = vim.g.colors.bg },

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

          PmenuThumb = {
            bg = colors.yellow,
          },

          CmpBorder = { fg = colors.yellow },

          -- DiagnosticVirtualTextError = { fg = colors.red, bg = "#2a0000" },

          NavicText = { fg = vim.g.colors.rose_beige },

          NvimTreeFolderName = { fg = colors.lavender },
          NvimTreeOpenedFolderName = { fg = colors.lavender },
          NvimTreeEmptyFolderName = { fg = colors.lavender },

          GitSignsCurrentLineBlame = {
            fg = colors.overlay1,
            italic = true,
          },

          -- lazy.nvim
          LazyH1 = {
            bg = colors.none,
            fg = colors.lavender,
            style = { "bold" },
          },
          LazyButton = {
            bg = colors.none,
            fg = colors.overlay0,
          },
          LazyButtonActive = {
            bg = colors.none,
            fg = colors.lavender,
            style = { "bold" },
          },
          LazySpecial = {
            fg = colors.green,
          },
        }
      end,
    })

    vim.cmd.colorscheme("catppuccin")
  end,
}
