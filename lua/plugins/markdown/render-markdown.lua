return {
  "MeanderingProgrammer/render-markdown.nvim",
  enabled = true,
  ft = "markdown",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local rm = require("render-markdown")

    local opts = {
      enabled = true,
      debounce = 20, -- reduce debounce ms for proper render on fast current line move
      render_modes = { "n", "c", "t", "i", "v", "V" },
      -- When enabled, reveal raw Markdown on the cursor line by hiding plugin decorations.
      anti_conceal = {
        enabled = false,
      },
      completions = {
        lsp = {
          enabled = true,
        },
      },
      win_options = {
        conceallevel = {
          default = vim.o.conceallevel,
          rendered = 0,
        },
      },
      sign = {
        priority = 5, -- lower than gitsigns' default sign_priority (6)
      },
      heading = {
        icons = {},
        sign = false,
      },
      link = {
        enabled = false,
      },
      code = {
        enabled = true,
        -- Determines how the top / bottom of code block are rendered.
        border = "thick",
        width = "full", -- block | full
        -- Turn on / off inline code related rendering.
        inline = true,
        -- Padding to add to the left & right of inline code.
        -- inline_pad = 1, -- set padding 1 for ` char space
      },
      latex = {
        enabled = false,
      },
    }

    rm.setup(opts)

    -- Resolve each heading highlight first because nvim_set_hl replaces its definition.
    -- This preserves the default background while adding bold.
    for level = 1, 6 do
      local group = "RenderMarkdownH" .. level .. "Bg"
      local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
      vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", highlight, { bold = true }))
    end

    vim.api.nvim_set_hl(0, "RenderMarkdownCode", {
      bg = vim.g.colors.brown,
    })
    vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", {
      fg = vim.g.colors.pink,
      bg = vim.g.colors.brown,
    })
    -- vim.api.nvim_set_hl(0, "RenderMarkdownBullet", {
    --   fg = vim.g.colors.orange,
    -- })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(ev)
        vim.keymap.set(
          "n",
          "<leader>mt",
          rm.buf_toggle,
          { desc = "Markdown render toggle", buffer = ev.buf, noremap = true }
        )
      end,
    })
  end,
}
