-- A plugin that allows you to easily manage external editor tooling such as LSP servers, DAP servers, linters, and formatters through a single interface
vim.pack.add({
  "https://github.com/williamboman/mason.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
})

vim.cmd.packadd("mason.nvim")
vim.cmd.packadd("mason-tool-installer.nvim")

local mason = require("mason")
local mason_tool_installer = require("mason-tool-installer")

-- enable mason and configure icons
mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

mason_tool_installer.setup({
  ensure_installed = {
    -- LSP servers
    "lua-language-server",
    "typescript-language-server",
    "rust-analyzer",
    "emmet-ls",
    "svelte-language-server",
    "marksman",
    "tailwindcss-language-server",
    "sqls",
    "css-lsp",
    "css-variables-language-server",
    "cssmodules-language-server",
    "some-sass-language-server",
    "html-lsp",
    "json-lsp",
    -- Formatters
    "prettier",
    "stylua",
    "isort",
    "black",
    "taplo",
    -- Linters
    "eslint_d",
    "pylint",
    "yamllint",
    "actionlint",
    -- etc
    "js-debug-adapter",
  },
})
