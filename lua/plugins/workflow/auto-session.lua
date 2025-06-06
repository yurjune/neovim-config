-- A plugin to auto-manage sessions
return {
  "rmagatti/auto-session",
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_restore_enabled = true,
      auto_session_suppress_dirs = { -- 세션 자동 저장 제외 디렉토리 목록
        "~/",
        "~/Dev/",
        "~/Downloads",
        "~/Documents",
        "~/Desktop/",
      },
      -- 세션 복원 후 실행할 명령어
      post_restore_cmds = {
        -- 세션 복원 시 파일 탐색기를 함께 열기
        -- vim.cmd('wincmd p'): 이전 창으로 이동하여 커서가 파일 탐색기에 위치하지 않도록
        "lua if not require('nvim-tree.view').is_visible() then require('nvim-tree.api').tree.open(); vim.cmd('wincmd p') end",
      },
    })

    local function restore_session_with_check()
      -- 세션 복원 실행 전, 현재 버퍼의 변경사항 확인
      if vim.bo.modified then
        local choice = vim.fn.confirm(
          "현재 버퍼에 저장되지 않은 변경사항이 있습니다. 계속할까요?",
          "&Yes\n&No",
          2
        )

        if choice ~= 1 then
          return
        end
      end
      auto_session.RestoreSession()
    end

    vim.keymap.set("n", "<leader>ss", auto_session.SaveSession, { desc = "Save Session" })
    vim.keymap.set("n", "<leader>sd", function()
      auto_session.DeleteSession()
      vim.notify("Session deleted", vim.log.levels.INFO, { title = "Auto Session" })
    end, { desc = "Delete Session" })
    vim.keymap.set("n", "<leader>sr", restore_session_with_check, { desc = "Restore Session with check" })
  end,
}
