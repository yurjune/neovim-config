return {
  "SmiteshP/nvim-navic",
  config = function()
    local navic = require("nvim-navic")

    ---@diagnostic disable-next-line: missing-fields
    navic.setup({
      highlight = true,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "BufWinEnter", "BufFilePost", "LspAttach" }, {
      callback = function()
        if not navic.is_available() then
          return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local winbarTxt = "%{%v:lua.require'nvim-navic'.get_location()%}"
        vim.api.nvim_buf_set_option(bufnr, "winbar", winbarTxt)
      end,
    })
  end,
}
