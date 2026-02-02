-- A plugin for managing comment
return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  config = function()
    local comment = require("Comment")
    local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

    comment.setup({
      padding = true, -- Add a space between comment and the line
      sticky = true, -- Whether the cursor should stay at its position
      ignore = nil, -- Lines to be ignored while (un)comment

      -- LHS of toggle mappings in NORMAL mode
      toggler = {
        line = "gcc",
        block = "gbc",
      },
      -- LHS of operator-pending mappings in NORMAL and VISUAL mode
      opleader = {
        line = "gc",
        block = "gb",
      },
      -- LHS of extra mappings
      extra = {
        above = "gcO", ---Add comment on the line above
        below = "gco",
        eol = "gcA",
      },
      -- If given `false` then the plugin won't create any mappings
      mappings = {
        -- Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
        basic = true,
        extra = true,
      },

      pre_hook = ts_context_commentstring.create_pre_hook(),
      ---@diagnostic disable-next-line
      post_hook = nil,
    })
  end,
}
