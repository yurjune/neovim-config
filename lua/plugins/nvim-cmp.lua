-- A completion engine plugin
return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer", -- source for text in buffer
    "hrsh7th/cmp-path", -- source for file system paths
    "hrsh7th/cmp-cmdline", -- for command line autocompletion
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp", -- install jsregexp (optional!).
    },
    "saadparwaiz1/cmp_luasnip", -- for autocompletion
    "rafamadriz/friendly-snippets", -- useful snippets
    "onsails/lspkind.nvim", -- vs-code like pictograms
  },

  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")
    local from_vscode = require("luasnip.loaders.from_vscode")

    cmp.setup({
      enabled = function()
        local filetype = vim.bo.filetype
        if filetype == "markdown" then
          return false
        end
        return true
      end,

      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },

      -- configure how nvim-cmp interacts with snippet engine
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
        ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = function() -- toggle suggestions
          if cmp.visible() then
            cmp.abort()
          else
            cmp.complete()
          end
        end,
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        -- ["<Tab>"] = cmp.mapping.confirm({ select = true }),
      }),

      -- sources for autocompletion
      sources = cmp.config.sources({
        { name = "nvim_lsp" }, -- lsp server
        { name = "buffer" }, -- text within current buffer
        { name = "luasnip" }, -- snippets
        { name = "path" }, -- file system paths
        -- { name = "copilot" }, -- integrate with copilot.cmp
        -- { name = "supermaven" }, -- integrate with supermaven.nvim
        -- { name = "render-markdown" },
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
      }),

      formatting = {
        format = function(entry, item)
          -- integrate nvim-highlight-colors to nvim-cmp
          local color_item = require("nvim-highlight-colors").format(entry, {
            kind = item.kind,
          })

          -- configure lspkind for vs-code like pictograms in completion menu
          item = lspkind.cmp_format({
            maxwidth = 100,
            ellipsis_char = "...",
            symbol_map = {
              Copilot = "", -- integrate with copilot.cmp
              Supermaven = "", -- integrate with supermaven.nvim
            },
          })(entry, item)

          if color_item.abbr_hl_group then
            item.kind_hl_group = color_item.abbr_hl_group
            item.kind = color_item.abbr
          end

          return item
        end,
      },

      window = {
        completion = {
          border = "rounded",
          winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
        },
        documentation = {
          border = "rounded",
          winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
        },
      },
    })

    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
    })

    -- To use existing VSCode style snippets from a plugin (e.g. rafamadriz/friendly-snippets)
    from_vscode.lazy_load()

    -- To use my own custom VSCode snippets
    from_vscode.load({
      paths = {
        -- NOTE: It's mandatory to have a 'package.json' file in the snippet directory
        vim.fn.stdpath("config") .. "/lua/snippets",
      },
    })

    -- luasnip 의 tabstop/placeholder(ex. $1, $2) 에 대한 키매핑
    vim.keymap.set({ "i", "s" }, "<C-f>", function()
      return luasnip.jumpable(1) and "<Plug>luasnip-jump-next" or "<C-f>"
    end, { expr = true })

    vim.keymap.set({ "i", "s" }, "<C-d>", function()
      return luasnip.jumpable(-1) and "<Plug>luasnip-jump-prev" or "<C-d>"
    end, { expr = true })
  end,
}
