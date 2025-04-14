vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- 줄바꿈 시 주석 지속 제거 옵션
    -- r: enter 명령인 경우 주석 지속
    -- o: 'o' 또는 'O' 명령인 경우 주석 지속
    vim.opt_local.formatoptions:remove({ "o" })
  end,
})
