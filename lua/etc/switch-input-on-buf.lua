-- Switch input source when leave or enter specific buffer
-- Needs specific config in Hammerspoon

local hs_cli = "/usr/local/bin/hs"
local hs_module = "nvimInputSource"

local function call_hammerspoon(method)
  local command = hs_module .. "." .. method .. "()" -- ex) nvimInputSource.switchToEnglish()
  vim.fn.jobstart({
    hs_cli,
    "-c",
    command,
  }, {
    detach = true, -- prevent killing hs process when exit
  })
end

local augroup = vim.api.nvim_create_augroup("SwitchInputOnBuf", { clear = true })

vim.api.nvim_create_autocmd("BufLeave", {
  group = augroup,
  pattern = vim.g.sidekick_buf_pattern,
  callback = function()
    call_hammerspoon("switchToEnglish")
  end,
})
