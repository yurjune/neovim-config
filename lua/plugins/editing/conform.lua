if vim.g.leetcode then
  return
end

vim.pack.add({
  "https://github.com/stevearc/conform.nvim",
})
vim.cmd.packadd("conform.nvim")

local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    -- "eslint_d" 를 추가해야 린트 결과를 포맷팅
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
  },
  -- formatters = {
  --   prettier = {
  --     prepend_args = function(_, ctx)
  --       if vim.bo[ctx.buf].filetype == "markdown" then
  --         return { "--tab-width", "4" }
  --       end
  --       return {}
  --     end,
  --   },
  -- },

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
