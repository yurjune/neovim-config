-- A plugin to highlight and search for todo comments
return {
  "folke/todo-comments.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local todo = require("todo-comments")

    todo.setup({
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "FIXIT", "BUG" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        WARN = { icon = " ", color = "warning", alt = { "WARNING" } },
        HACK = { icon = " ", color = "warning" },
        TODO = { icon = " ", color = "info" },
      },
      search = {
        pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon
      },
      highlight = {
        pattern = [[.*<(KEYWORDS)\s*]], -- match without the extra colon
        before = "",
        keyword = "wide",
        after = "fg",
      },
    })
  end,
}
