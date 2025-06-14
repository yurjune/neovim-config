vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- option for remove continue commenting when line changes
    -- r: continue commenting when line changed by enter
    -- o: continue commenting when line changed by o or O command
    vim.opt_local.formatoptions:remove({ "o" })
  end,
})

-- To keep fold state
vim.api.nvim_create_autocmd("BufWinLeave", {
  pattern = "*",
  callback = function()
    local is_normal_buffer = vim.bo.filetype ~= "" and vim.bo.buftype == ""
    if is_normal_buffer then
      -- make(save) view state: ex) folds, cursor position, etc.
      vim.cmd("silent! mkview")
    end
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*",
  callback = function()
    local is_normal_buffer = vim.bo.filetype ~= "" and vim.bo.buftype == ""
    if is_normal_buffer then
      vim.cmd("silent! loadview")
    end
  end,
})
