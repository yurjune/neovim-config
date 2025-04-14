-- A plugin to auto-manage sessions
return {
  "rmagatti/auto-session",
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_restore_enabled = true, -- true 이면 neovim 실행 시 자동 세션 복원
      auto_session_suppress_dirs = { -- 세션 자동 저장 제외 디렉토리 목록
        "~/",
        "~/Dev/",
        "~/Downloads",
        "~/Documents",
        "~/Desktop/",
      },
      post_restore_cmds = { -- 세션 복원 후 실행할 명령어
        -- 세션 복원 시 파일 탐색기를 함께 열기
        -- vim.cmd('wincmd p'): 이전 창으로 이동: 커서가 파일 탐색기에 위치하지 않도록 합니다.
        "lua if not require('nvim-tree.view').is_visible() then require('nvim-tree.api').tree.open(); vim.cmd('wincmd p') end",
      },
    })

    vim.keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session" })
    vim.keymap.set("n", "<leader>wd", "<cmd>SessionDelete<CR>", { desc = "Delete session" })

    vim.keymap.set("n", "<leader>wr", function()
      -- 세션 복원 실행 전, 현재 버퍼에 변경사항을 확인하기
      if vim.bo.modified then
        local choice = vim.fn.confirm(
          "현재 버퍼에 저장되지 않은 변경사항이 있습니다. 계속할까요?",
          "&Yes\n&No",
          2
        )

        if choice ~= 1 then
          return -- 사용자가 No를 선택하면 복원 취소
        end
      end
      -- 사용자가 Yes를 선택하거나 변경사항이 없으면 세션 복원 실행
      vim.cmd("SessionRestore")
    end, { desc = "Restore last workspace session" })
  end,
}
