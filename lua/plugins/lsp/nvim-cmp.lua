-- A plugin that provides a completion engine.
vim.pack.add({
  -- tells LSP servers that nvim-cmp can handle advanced features (auto-imports, snippets, etc.)
  -- without this: useState won't appear unless you manually write 'import { useState } from "react"'
  -- with this: useState appears in completion even without import, and adds the import when selected
  "https://github.com/hrsh7th/cmp-nvim-lsp",
  "https://github.com/hrsh7th/cmp-buffer", -- source: words from current buffer (variables/functions you've already typed)
  "https://github.com/hrsh7th/cmp-path", -- source: file system paths (./src/, ../components/Header.tsx)
  "https://github.com/hrsh7th/cmp-cmdline", -- source: vim commands in command line mode (:colorscheme, /search patterns)
  "https://github.com/L3MON4D3/LuaSnip", -- snippet engine: expands templates (e.g., rfc → React functional component)
  "https://github.com/saadparwaiz1/cmp_luasnip", -- source: connects LuaSnip snippets to nvim-cmp completion list
  "https://github.com/rafamadriz/friendly-snippets", -- snippet data: pre-made templates for React, Vue, Python, etc.
  "https://github.com/onsails/lspkind.nvim", -- UI enhancement: adds VSCode-like icons (ƒ  󰊕 etc.)
  "https://github.com/hrsh7th/nvim-cmp",
})
vim.cmd.packadd("cmp-nvim-lsp")
vim.cmd.packadd("cmp-buffer")
vim.cmd.packadd("cmp-path")
vim.cmd.packadd("cmp-cmdline")
vim.cmd.packadd("LuaSnip")
vim.cmd.packadd("cmp_luasnip")
vim.cmd.packadd("friendly-snippets")
vim.cmd.packadd("lspkind.nvim")
vim.cmd.packadd("nvim-cmp")

local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")
local from_vscode = require("luasnip.loaders.from_vscode")

cmp.setup({
  enabled = function()
    local filetype = vim.bo.filetype
    local exlcude_ft = {
      "TelescopePrompt",
      "markdown",
    }
    if vim.tbl_contains(exlcude_ft, filetype) then
      return false
    end
    if vim.g.leetcode then
      return false
    end
    return true
  end,

  -- sources for autocompletion (order matters - higher priority first)
  sources = cmp.config.sources({
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
    -- ["<Tab>"] = cmp.mapping.confirm({ select = true }),
  }),

  -- configure how nvim-cmp interacts with snippet engine
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  -- customize how completions are formatted
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

  -- controls completion popup menu functions
  completion = {
    -- menu: show popup menu for completions
    -- menuone: show popup menu even if there's only one completion
    -- preview: show preview window for completions
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
})

-- Apply completions in command line
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

-- Keymaps of luasnip about tabstop/placeholder(ex. $1, $2)
vim.keymap.set({ "i", "s" }, "<C-f>", function()
  return luasnip.jumpable(1) and "<Plug>luasnip-jump-next" or "<C-f>"
end, { expr = true })

vim.keymap.set({ "i", "s" }, "<C-d>", function()
  return luasnip.jumpable(-1) and "<Plug>luasnip-jump-prev" or "<C-d>"
end, { expr = true })
