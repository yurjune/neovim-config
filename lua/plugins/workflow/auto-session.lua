-- A plugin to auto-manage sessions
return {
  "rmagatti/auto-session",
  config = function()
    local auto_session = require("auto-session")
    local should_close_sidekick = true

    -- This causes screen blinking when restoring session
    local function restore_nvim_tree()
      if not require("nvim-tree.view").is_visible() then
        require("nvim-tree.api").tree.open()
        vim.cmd("wincmd p") -- move cursor back to the previous window
        vim.cmd("redraw") -- minimize screen blinking
      end
    end

    -- If sideclick CLI buffer is open when exit neovim,
    -- it generate a new tmux session when restoring session.
    -- So close it before saving session.
    local function close_sidekick_buf()
      if should_close_sidekick == false then
        return
      end

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)

        if string.find(vim.fn.bufname(buf), "term://", 1, true) then
          vim.api.nvim_win_close(win, true)
        end
      end
    end

    auto_session.setup({
      auto_save = true, -- Enables/disables auto saving session on exit
      auto_restore = true,
      suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
      post_restore_cmds = {
        restore_nvim_tree,
      },
      pre_save_cmds = {
        close_sidekick_buf,
      },
    })

    local function restore_session_with_check()
      -- check current buffer modified before restoring session
      if vim.bo.modified then
        local choice = vim.fn.confirm(
          "The current buffer has unsaved changes. Do you want to continue and lose those changes?",
          "&Yes\n&No",
          2
        )

        if choice ~= 1 then
          return
        end
      end
      auto_session.restore_session()
    end

    local function save_session()
      should_close_sidekick = false
      auto_session.save_session()
      should_close_sidekick = true
    end

    vim.keymap.set("n", "<leader>ss", save_session, { desc = "Save Session" })

    vim.keymap.set("n", "<leader>sd", function()
      auto_session.delete_session()
      vim.notify("Session deleted", vim.log.levels.INFO, { title = "Auto Session" })
    end, { desc = "Delete Session" })

    vim.keymap.set("n", "<leader>sr", restore_session_with_check, { desc = "Restore Session with check" })
  end,
}
