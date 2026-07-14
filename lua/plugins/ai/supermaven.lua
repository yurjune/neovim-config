-- A plugin for inline code completion
return {
  "supermaven-inc/supermaven-nvim",
  enabled = true,
  event = "InsertEnter",
  cond = function()
    return not vim.g.leetcode
  end,
  config = function()
    local sp = require("supermaven-nvim")
    local api = require("supermaven-nvim.api")
    local state_file = vim.fn.stdpath("state") .. "/supermaven_enabled"

    local function load_enabled()
      return vim.uv.fs_stat(state_file) ~= nil
    end

    local function save_enabled(enabled)
      if enabled then
        vim.fn.writefile({ "1" }, state_file)
      else
        vim.fn.delete(state_file)
      end
    end

    sp.setup({
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      ignore_filetypes = {
        -- "markdown",
      },
      color = {
        -- suggestion_color = ""
        cterm = 244,
      },
      log_level = "info", -- set to "off" to disable logging completely
      disable_inline_completion = false, -- disables inline completion for use with cmp
      disable_keymaps = false, -- disables built in keymaps for more manual control
    })

    -- restore previous state
    if not load_enabled() and api.is_running() then
      api.stop()
    elseif load_enabled() and not api.is_running() then
      api.start()
    end

    vim.keymap.set("n", "<leader>cc", function()
      local enabled = not api.is_running()

      if enabled then
        api.start()
        vim.notify("Supermaven enabled", vim.log.levels.INFO, { title = "Supermaven" })
      else
        api.stop()
        vim.notify("Supermaven disabled", vim.log.levels.INFO, { title = "Supermaven" })
      end

      save_enabled(enabled)
    end, { desc = "Toggle Supermaven" })
  end,
}
