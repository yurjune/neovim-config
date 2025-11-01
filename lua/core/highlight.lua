vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "Visual", {
      bg = vim.g.colors_transparent.cursorline,
    })
    vim.api.nvim_set_hl(0, "CursorLine", {
      bg = vim.g.colors_transparent.cursorline,
    })
    vim.api.nvim_set_hl(0, "CursorLineNr", {
      fg = vim.g.colors.rose_beige,
    })
    vim.api.nvim_set_hl(0, "Folded", {
      bg = vim.g.colors_transparent.cursorline,
    })
  end,
})
