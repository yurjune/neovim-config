-- A plugin to auto-manage sessions
return {
  "rmagatti/auto-session",
  config = function()
    local auto_session = require("auto-session")

    -- This causes screen blinking when restoring session
    local function restore_nvim_tree()
      if not require("nvim-tree.view").is_visible() then
        require("nvim-tree.api").tree.open()
        vim.cmd("wincmd p") -- move cursor back to the previous window
        vim.cmd("redraw") -- minimize screen blinking
      end
    end

    auto_session.setup({
      auto_save = true, -- Enables/disables auto saving session on exit
      auto_restore = true,
      suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
      post_restore_cmds = {
        restore_nvim_tree,
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
