--- An asynchronous linter plugin
if vim.g.leetcode then
  return
end

vim.pack.add({
  "https://github.com/mfussenegger/nvim-lint",
})
vim.cmd.packadd("nvim-lint")

local lint = require("lint")

lint.linters_by_ft = {
  javascript = { "eslint_d" },
  typescript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  svelte = { "eslint_d" },
  -- python = { "pylint" },
  rust = { "clippy" },
  c = { "clangtidy" }, -- brew install llvm
  cpp = { "clangtidy" },
  -- yaml = { "yamllint" },
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
local lint_condition = {
  "BufEnter", -- 버퍼로 들어갈 때
  "BufWritePost", -- 버퍼 내용을 파일에 저장할 때
  "TextChanged", -- 노말 모드에서 텍스트가 변경될 때
  "InsertLeave", -- 삽입 모드에서 나갈 때
}

-- Auto linting trigger
local lint_debounce_timer = vim.loop.new_timer()
vim.api.nvim_create_autocmd(lint_condition, {
  group = lint_augroup,
  callback = function()
    if lint_debounce_timer == nil then
      return
    end

    lint_debounce_timer:stop()
    lint_debounce_timer:start(300, 0, vim.schedule_wrap(lint.try_lint))
  end,
})

-- GitHub Actions workflow linting with actionlint
local actionlint_debounce_timer = vim.loop.new_timer()
vim.api.nvim_create_autocmd(lint_condition, {
  group = lint_augroup,
  pattern = {
    "*/.github/workflows/*.yml",
    "*/.github/workflows/*.yaml",
  },
  callback = function()
    if actionlint_debounce_timer == nil then
      return
    end

    actionlint_debounce_timer:stop()
    actionlint_debounce_timer:start(
      300,
      0,
      vim.schedule_wrap(function()
        lint.try_lint("actionlint")
      end)
    )
  end,
})

vim.keymap.set("n", "<leader>ll", function()
  vim.notify("Linting triggered", vim.log.levels.INFO, { title = "nvim-lint" })
  lint.try_lint()
end, { desc = "Trigger linting for current file" })
