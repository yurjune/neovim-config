-- A plugin to see PR on Github
-- must install 'gh'
return {
  "h3pei/trace-pr.nvim",
  keys = {
    { "<leader>gg", "<cmd>TracePR<CR>", desc = "Open PR for current line" },
  },
  config = true,
}
