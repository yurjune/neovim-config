--- Automatically completes the closed brace of any pair such as {} ,(), []
vim.pack.add({
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/hrsh7th/nvim-cmp",
})
vim.cmd.packadd("nvim-autopairs")
vim.cmd.packadd("nvim-cmp")

local autopairs = require("nvim-autopairs")
autopairs.setup({
  check_ts = true, -- enable treesitter
  ts_config = {
    lua = { "string" }, -- don't add pairs in lua string treesitter nodes
    javascript = { "template_string" },
  },
})

local ok_cmp, cmp = pcall(require, "cmp")
if ok_cmp then
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  -- make autopairs and completion work together
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end
