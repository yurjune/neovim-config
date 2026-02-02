-- A plugin for formatting code
return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cond = function()
    return not vim.g.leetcode
  end,
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        -- ESLint works with conform.nvim because:
        -- 1. ESLint provides `--fix` flag for auto-fixing
        -- 2. conform.nvim internally runs `eslint_d --fix` on single files
        -- 3. It supports stdin/stdout processing for per-file formatting
        javascript = { "prettier", "eslint_d" },
        typescript = { "prettier", "eslint_d" },
        javascriptreact = { "prettier", "eslint_d" },
        typescriptreact = { "prettier", "eslint_d" },
        svelte = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        toml = { "taplo" },
        -- markdown = { "prettier" },
        graphql = { "prettier" },
        lua = { "stylua" },
        python = { "isort", "black" },
        rust = { "rustfmt" },
        c = { "clang_format" }, -- brew install llvm
        cpp = { "clang_format" },
      },

      formatters = {
        clang_format = {
          prepend_args = {
            "--style={BasedOnStyle: llvm, AllowShortFunctionsOnASingleLine: None}",
          },
        },
      },

      -- prefer format_after_save then format_on_save since save with formatting always blocks UI
      -- process: save -> format -> resave
      -- ref. https://github.com/stevearc/conform.nvim/issues/401#issuecomment-2108453243
      format_after_save = function(bufnr)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        local filename = vim.fn.fnamemodify(bufname, ":t")

        local exclude_files = {
          "lazy-lock.json",
          "package-lock.json",
        }

        for _, exclude_file in ipairs(exclude_files) do
          if filename == exclude_file then
            return nil
          end
        end

        return {
          async = true,
          lsp_format = "never",
          timeout_ms = 2000,
        }
      end,
    })

    vim.keymap.set({ "n", "v" }, "<leader>lf", function()
      vim.notify("Formatting triggered", vim.log.levels.INFO, { title = "conform.nvim" })
      conform.format({
        async = true,
        lsp_format = "never",
        timeout_ms = 2000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
