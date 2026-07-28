-- Switch input source when leaving or entering insert mode or a specific buffer
-- Needs specific config in Hammerspoon

local hs_module = "nvimInputSource"
local hs_cli = vim.fn.exepath("hs")

local function call_hammerspoon(method)
  local command = hs_module .. "." .. method .. "()" -- ex) nvimInputSource.enterInsert()
  vim.fn.jobstart({
    hs_cli,
    "-c",
    command,
  }, {
    -- Close stdin so `hs` exits after running the command.
    -- Otherwise, each call leaves another `hs` process running.
    stdin = "null",
  })
end

local function save_and_switch_to_english()
  call_hammerspoon("leaveInsert")
end

local function restore_saved_input_source()
  call_hammerspoon("enterInsert")
end

local augroup = vim.api.nvim_create_augroup("SwitchInputSource", { clear = true })

vim.api.nvim_create_autocmd("InsertLeave", {
  group = augroup,
  pattern = "*",
  desc = "Save input source and switch to English",
  callback = save_and_switch_to_english,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = augroup,
  pattern = "*",
  desc = "Restore saved input source",
  callback = restore_saved_input_source,
})

vim.api.nvim_create_autocmd("BufLeave", {
  group = augroup,
  pattern = vim.g.sidekick_buf_pattern,
  desc = "Save input source and switch to English",
  callback = save_and_switch_to_english,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  pattern = vim.g.sidekick_buf_pattern,
  desc = "Restore saved input source",
  callback = restore_saved_input_source,
})
