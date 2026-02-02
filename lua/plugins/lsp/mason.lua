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
        -- TS/JS
        "typescript-language-server",
        "prettier",
        "eslint_d",
        "js-debug-adapter",
        "svelte-language-server",
        -- C/C++: managed manually
        -- Rust: managed by rustup
        -- Python
        "pyright",
        "pylint",
        "isort",
        "black",
        -- Lua
        "lua-language-server",
        "stylua",
        -- html
        "html-lsp",
        "emmet-ls",
        -- CSS
        "css-lsp",
        "css-variables-language-server",
        "cssmodules-language-server",
        "some-sass-language-server",
        "tailwindcss-language-server",
        -- etc
        "marksman",
        "sqls",
        "json-lsp",
        "taplo",
        "yamllint",
        "actionlint",
      },
    })
  end,
}
