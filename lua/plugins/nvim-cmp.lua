-- A completion engine plugin
-- 다양한 소스로부터 자동완성 지원: LSP, Luasnip, Tressiter, Custom snippets, and more
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

    -- To use existing VS Code style snippets from a plugin (e.g. rafamadriz/friendly-snippets)
    from_vscode.lazy_load()

    -- To use my own custom snippets
    from_vscode.load({
      paths = {
        -- NOTE: It's mandatory to have a 'package.json' file in the snippet directory
        vim.fn.stdpath("config") .. "/lua/snippets",
      },
    })

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },

      snippet = { -- configure how nvim-cmp interacts with snippet engine
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
        { name = "nvim_lsp" },
        { name = "buffer" }, -- text within current buffer
        { name = "luasnip" }, -- snippets
        { name = "path" }, -- file system paths
      }),

      -- configure lspkind for vs-code like pictograms in completion menu
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 100,
          ellipsis_char = "...",
        }),
      },
    })

    -- `/` 검색 명령어에 대한 설정
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- `:` 명령어 모드에 대한 설정
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
    })
  end,
}
