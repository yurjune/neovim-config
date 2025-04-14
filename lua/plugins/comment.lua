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
      -- for commenting tsx, jsx, svelte, html files
      pre_hook = ts_context_commentstring.create_pre_hook(),
    })

    -- keymaps
    -- gcc: 현재 라인 주석처리
    -- {visual}gc: 현재 블럭 주석처리
    -- gc{motion}: 모션 지정 범위 주석처리
  end,
}
