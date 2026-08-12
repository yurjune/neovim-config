-- A plugin to auto-manage sessions
return {
  "rmagatti/auto-session",
  config = function()
    local auto_session = require("auto-session")
    local should_close_sidekick = true

    -- If sideclick CLI buffer is open when exit neovim,
    -- it generate a new tmux session when restoring session.
    -- So close it before saving session.
    local function close_sidekick_buf()
      if should_close_sidekick == false then
        return
      end

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)

        if vim.bo[buf].filetype == vim.g.sidekick_buf_filetype then
          vim.api.nvim_win_close(win, true)
        end
      end
    end

    auto_session.setup({
      auto_save = true,
      auto_restore = true,
      suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
      pre_save_cmds = {
        close_sidekick_buf,
      },
    })

    vim.keymap.set("n", "<leader>ss", function()
      -- prevent closing sidekick buffer
      should_close_sidekick = false
      auto_session.save_session()
      should_close_sidekick = true
    end, { desc = "Save Session" })

    vim.keymap.set("n", "<leader>sd", function()
      auto_session.delete_session()
      vim.notify("Session deleted", vim.log.levels.INFO, { title = "Auto Session" })
    end, { desc = "Delete Session" })
  end,
}
