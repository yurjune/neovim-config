vim.pack.add({ "https://github.com/SmiteshP/nvim-navic" })
vim.cmd.packadd("nvim-navic")

local navic = require("nvim-navic")

navic.setup({
  highlight = true,
})

vim.api.nvim_create_autocmd({ "CursorMoved", "BufWinEnter", "BufFilePost", "LspAttach" }, {
  callback = function()
    if not navic.is_available() then
      return
    end

    local winbarTxt = "%{%v:lua.require'nvim-navic'.get_location()%}"
    vim.opt_local.winbar = winbarTxt
  end,
})

vim.api.nvim_set_hl(0, "NavicText", {
  fg = vim.g.colors.rose_beige,
})
