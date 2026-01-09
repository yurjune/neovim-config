-- A plugin for inline code completion
if vim.g.leetcode then
  return
end

vim.pack.add({ "https://github.com/supermaven-inc/supermaven-nvim" })
vim.cmd.packadd("supermaven-nvim")

local sp = require("supermaven-nvim")
local api = require("supermaven-nvim.api")

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

vim.keymap.set("n", "<leader>cc", function()
  if api.is_running() then
    vim.notify("Supermaven disabled", vim.log.levels.INFO, { title = "Supermaven" })
  else
    vim.notify("Supermaven enabled", vim.log.levels.INFO, { title = "Supermaven" })
  end
  api.toggle()
end, { desc = "Toggle Supermaven" })
