-- A plugin to see PR on Github
-- must install 'gh'
return {
  "h3pei/trace-pr.nvim",
  keys = {
    { "<leader>gh", "<cmd>TracePR<CR>", desc = "Open PR/commit for current line in github" },
  },
  config = true,
}
