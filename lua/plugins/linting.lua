return {
  "mfussenegger/nvim-lint",
  enabled = true,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      svelte = { "eslint_d" },
      python = { "pylint" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    -- 자동 린팅 트리거
    vim.api.nvim_create_autocmd({
      "BufEnter", -- 버퍼로 들어갈 때
      "BufWritePost", -- 버퍼 내용을 파일에 저장할 때
      "InsertLeave", -- 삽입 모드에서 나갈 때
      "TextChanged", -- 노말 모드에서 텍스트가 변경될 때
    }, {
      group = lint_augroup,

      -- 몇몇 이벤트의 경우 빈번하게 린팅을 시도할 수 있어 디바운스 적용
      -- ex) TextChanged
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
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
