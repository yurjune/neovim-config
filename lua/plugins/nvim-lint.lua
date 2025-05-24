-- An asynchronous linter plugin
return {
  "mfussenegger/nvim-lint",
  enabled = true,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      -- javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      svelte = { "eslint_d" },
      -- python = { "pylint" },
      rust = { "clippy" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    -- Auto linting trigger
    vim.api.nvim_create_autocmd({
      "BufEnter", -- 버퍼로 들어갈 때
      "BufWritePost", -- 버퍼 내용을 파일에 저장할 때
      "InsertLeave", -- 삽입 모드에서 나갈 때
      "TextChanged", -- 노말 모드에서 텍스트가 변경될 때
    }, {
      group = lint_augroup,

      -- Some events frequently trigger linting, so apply debounce (ex. TextChanged)
      callback = function()
        if debounce_timer then
          vim.loop.timer_stop(debounce_timer)
          debounce_timer:close()
        end
        debounce_timer = vim.loop.new_timer()
        debounce_timer:start(
          300,
          0,
          vim.schedule_wrap(function()
            lint.try_lint()
          end)
        )
      end,
    })

    vim.keymap.set("n", "<leader>ll", function()
      vim.notify("Linting triggered", vim.log.levels.INFO, { title = "nvim-lint" })
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
