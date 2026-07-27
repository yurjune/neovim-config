-- Switch input source when leave or enter insert mode
-- Needs specific config in Hammerspoon

local hs_cli = "/usr/local/bin/hs"
local hs_module = "nvimInputSource"

local function call_hammerspoon(method)
  local command = hs_module .. "." .. method .. "()" -- ex) nvimInputSource.enterInsert()
  vim.fn.jobstart({
    hs_cli,
    "-c",
    command,
  }, {
    detach = true, -- prevent killing hs process when exit
  })
end

local augroup = vim.api.nvim_create_augroup("SwitchInputOnInsert", { clear = true })

vim.api.nvim_create_autocmd("InsertLeave", {
  group = augroup,
  pattern = "*",
  desc = "Save input source and switch to English",
  callback = function()
    call_hammerspoon("leaveInsert")
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = augroup,
  pattern = "*",
  desc = "Restore saved input source",
  callback = function()
    call_hammerspoon("enterInsert")
  end,
})
