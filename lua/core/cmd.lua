vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- option for remove continue commenting when line changes
    -- r: continue commenting when line changed by enter
    -- o: continue commenting when line changed by o or O command
    vim.opt_local.formatoptions:remove({ "o" })
  end,
})

-- for keep fold state
vim.api.nvim_create_autocmd("BufWinLeave", {
  pattern = "*",
  callback = function()
    -- exclude empty buffer and special buffers(like help)
    if vim.bo.filetype ~= "" and vim.bo.buftype == "" then
      vim.cmd("silent! mkview")
    end
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "" and vim.bo.buftype == "" then
      vim.cmd("silent! loadview")
    end
  end,
})
