-- A plugin for inline code completion
if vim.g.leetcode then
  return
end

vim.pack.add({ "https://github.com/zbirenbaum/copilot.lua" })
vim.cmd.packadd("copilot.lua")

if vim.g.copilot_enabled ~= 1 then
  return
end
require("copilot").setup({
  -- if you use copilot-cmp, disabled panel and suggestion for better use
  panel = {
    enabled = false,
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    hide_during_completion = true,
    debounce = 50,
    trigger_on_accept = true,
    keymap = {
      accept = "<Tab>",
      accept_word = false,
      accept_line = false,
      -- next = "<M-j>",
      -- prev = "<M-k>",
      dismiss = "<C-]>",
    },
    filetypes = {
      yaml = false,
      markdown = true,
      help = false,
      gitcommit = false,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ["."] = false,
    },
  },
})

local copilot_enabled = vim.g.copilot_enabled
vim.keymap.set("n", "<leader>ct", function()
  if copilot_enabled == 0 then
    vim.cmd("Copilot enable")
    copilot_enabled = 1
    vim.notify("Copilot enabled", vim.log.levels.INFO, { title = "Copilot" })
  else
    vim.cmd("Copilot disable")
    copilot_enabled = 0
    vim.notify("Copilot disabled", vim.log.levels.INFO, { title = "Copilot" })
  end
end, { desc = "Toggle Copliot" })
