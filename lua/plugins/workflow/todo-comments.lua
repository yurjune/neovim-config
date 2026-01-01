-- A plugin to highlight and search for todo comments
vim.pack.add({
  "https://github.com/folke/todo-comments.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
})
vim.cmd.packadd("todo-comments.nvim")
vim.cmd.packadd("plenary.nvim")

local todo = require("todo-comments")
local keymap = vim.keymap

todo.setup({
  keywords = {
    FIX = {
      icon = " ", -- icon used for the sign, and in search results
      color = "error", -- can be a hex color, or a named color (see below)
      alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
      -- signs = false, -- configure signs for some keywords individually
    },
    TODO = { icon = " ", color = "info" },
    HACK = { icon = " ", color = "warning" },
    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
    TEST = { icon = "⏲ ", color = "test", alt = { "TESTING" } },
  },
  search = {
    pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon
  },
  highlight = {
    pattern = [[.*<(KEYWORDS)\s*]], -- match without the extra colon
    before = "", -- "fg" or "bg" or empty
    keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty.
    after = "fg", -- "fg" or "bg" or empty
  },
})

keymap.set("n", "]t", function()
  todo.jump_next()
end, { desc = "Next todo comment" })

keymap.set("n", "[t", function()
  todo.jump_prev()
end, { desc = "Prev todo comment" })
