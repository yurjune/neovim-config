return {
  "rmagatti/auto-session",
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_restore_enabled = false,
      auto_session_suppress_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
    })

    local keymap = vim.keymap

    -- w means write
    keymap.set(
      "n",
      "<leader>ws",
      "<cmd>SessionSave<CR>",
      { desc = "Save workspace session for current working directory" }
    )

    keymap.set("n", "<leader>wr", function()
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
    end, { desc = "Restore last workspace session for current directory" })
  end,
}
