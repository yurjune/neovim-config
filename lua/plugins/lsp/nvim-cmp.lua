-- A completion engine plugin
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- provide LSP completions to nvim-cmp
    "hrsh7th/cmp-buffer", -- provide words from current buffer to nvim-cmp
    "hrsh7th/cmp-path", -- provide filesystem path completions to nvim-cmp
    "hrsh7th/cmp-cmdline", -- provide vim command-line completions to nvim-cmp
    {
      -- Snippet engine: loads, expands, and manages snippets
      -- e.g. custom snippets, friendly-snippets
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp", -- optional regex transformation support
    },
    "saadparwaiz1/cmp_luasnip", -- provide snippets registered in LuaSnip to nvim-cmp
    "rafamadriz/friendly-snippets", -- collection of pre-made snippets (ex. uuid, date)
    "onsails/lspkind.nvim", -- UI enhancement: adds VSCode-like icons
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")
    local from_vscode = require("luasnip.loaders.from_vscode")

    cmp.setup({
      -- register completions sources (order matters - higher priority first)
      -- :CmpStatus to debug
      sources = vim.g.leetcode and {} or cmp.config.sources({
        { name = "nvim_lsp" }, -- from cmp-nvim-lsp
        { name = "buffer" }, -- from cmp-buffer
        { name = "luasnip" }, -- from cmp_luasnip
        { name = "path" }, -- from cmp-path
      }),

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
      }),

      -- customize how completions are formatted
      formatting = {
        format = function(entry, item)
          -- integrate nvim-highlight-colors to nvim-cmp
          local color_item = require("nvim-highlight-colors").format(entry, {
            kind = item.kind,
          })

          -- integrate lspkind to nvim-cmp
          item = lspkind.cmp_format({
            maxwidth = 100,
            ellipsis_char = "...",
          })(entry, item)

          if color_item.abbr_hl_group then
            item.kind_hl_group = color_item.abbr_hl_group
            item.kind = color_item.abbr
          end

          return item
        end,
      },

      -- controls completion popup menu functions
      completion = {
        -- menu: show popup menu when multiple matches exist
        -- menuone: show popup menu even if there's only one completion
        -- preview: show preview window for each completion
        -- noselect: don't select the completion automatically
        completeopt = "menu,menuone,preview,noselect",
      },

      -- customize UI styles for completion popup menu
      window = {
        -- completion list popup menu
        completion = {
          border = "rounded",
          winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
        },
        -- documentation popup menu for completions
        documentation = {
          border = "rounded",
          winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
        },
      },

      -- configure how nvim-cmp interacts with snippet engine
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
    })

    -- Apply completions in command line
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        -- higher priority
        { name = "path" },
      }, {
        -- fallback: when higher priority sources are not available
        { name = "cmdline" },
      }),
    })

    cmp.setup.filetype("markdown", {
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
      }),
    })

    -- authomatically import all vscode like snippets in runtimepath;
    -- ex) friendly-snippets
    from_vscode.lazy_load()

    -- import my own custom VSCode snippets
    from_vscode.load({
      paths = {
        -- NOTE: It's mandatory to have a 'package.json' file in the snippet directory
        vim.fn.stdpath("config") .. "/lua/snippets",
      },
    })

    -- Keymaps of luasnip about tabstop/placeholder(ex. $1, $2)
    vim.keymap.set({ "i", "s" }, "<C-;>", function()
      return luasnip.jumpable(1) and "<Plug>luasnip-jump-next" or "<C-;>"
    end, { expr = true })

    -- vim.keymap.set({ "i", "s" }, "<C-d>", function()
    --   return luasnip.jumpable(-1) and "<Plug>luasnip-jump-prev" or "<C-d>"
    -- end, { expr = true })

    vim.keymap.set("n", "<leader>pf", function()
      vim.api.nvim_feedkeys("o", "n", false)
      vim.schedule(function()
        luasnip.snip_expand(luasnip.snippet({ trig = "console_log_keymap" }, {
          luasnip.text_node('console.log("'),
          luasnip.insert_node(1),
          luasnip.text_node('"'),
          luasnip.insert_node(0),
          luasnip.text_node(")"),
        }))
      end)
    end, { desc = "Insert console.log on the next line" })

    vim.keymap.set("n", "<leader>pv", function()
      local word = vim.fn.expand("<cword>")
      local text = 'console.log("' .. word .. '", ' .. word .. ");"

      vim.fn.setreg("+", text, "V")
      vim.notify("Copied: " .. text, vim.log.levels.INFO)
    end, { desc = "Copy console.log to clipboard" })
  end,
}
