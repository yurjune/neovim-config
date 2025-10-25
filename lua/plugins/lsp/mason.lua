-- A plugin that allows you to easily manage external editor tooling such as LSP servers, DAP servers, linters, and formatters through a single interface
return {
  "williamboman/mason.nvim",
  dependencies = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
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
        "pylint",
        "eslint_d",
        "actionlint",
        -- etc
        "js-debug-adapter",
      },
    })
  end,
}
