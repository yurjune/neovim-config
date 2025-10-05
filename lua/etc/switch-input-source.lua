-- Switch input source when leave or enter specific buffer

-- check input-source name by 'im-select' command in terminal
local en_source = "com.apple.keylayout.ABC"
-- local ko_source = "com.apple.inputmethod.Korean.2SetKorean"   -- macOS default Korean(두벌식)
-- local ko_source = "org.youknowone.inputmethod.Gureum.han2" -- 구름 입력기(두벌식)

local function set_input_source_async(im)
  if not im or im == "" then
    return
  end
  vim.defer_fn(function()
    vim.fn.jobstart("im-select " .. im)
  end, 100)
end

local augroup = vim.api.nvim_create_augroup("AutoInputSource", { clear = true })

vim.api.nvim_create_autocmd("BufLeave", {
  group = augroup,
  pattern = vim.g.sidekick_buf_pattern,
  callback = function()
    set_input_source_async(en_source)
  end,
})
