local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }

vim.diagnostic.config({
  underline = true,
  update_in_insert = true,
  severity_sort = true,
  virtual_text = {
    prefix = "■",
    spacing = 4,
    source = "if_many",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = signs.Error,
      [vim.diagnostic.severity.WARN] = signs.Warn,
      [vim.diagnostic.severity.INFO] = signs.Info,
      [vim.diagnostic.severity.HINT] = signs.Hint,
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
    },
  },
  float = {
    border = "rounded",
    winhighlight = "Normal:DiagnosticFloat,FloatBorder:DiagnosticBorder",
  },
})

vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

vim.keymap.set("n", "<leader>db", function()
  require("telescope.builtin").diagnostics({ bufnr = 0 })
end, { desc = "Show current buffer diagnostics" })

vim.keymap.set("n", "<leader>dw", function()
  require("telescope.builtin").diagnostics({
    bufnr = nil, -- 0은 현재 버퍼
    severity = nil, -- nil 이면 모든 심각도 수준
    root_dir = nil, -- nil이면 모든 파일 포함 (전체 워크스페이스)
  })
end, { desc = "Show workspace diagnostics" })
