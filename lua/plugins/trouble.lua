-- A plugin to manage diagnostics
return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  opts = {
    focus = true,
  },
  cmd = "Trouble",
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
    {
      "<leader>xb",
      "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
      desc = "Open trouble current buffer diagnostics",
    },
    { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Open trouble quickfix list" }, -- 기존 qflist 를 Trouble UI 로 표시
    { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Open trouble location list" }, -- 기존 loclist 를 Trouble UI 로 표시
  },
}
