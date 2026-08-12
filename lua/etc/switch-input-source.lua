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

local function restore_saved_source()
  call_hammerspoon("restoreSavedSource")
end

local function save_source_and_switch_to_english()
  call_hammerspoon("saveSourceAndSwitchToEnglish")
end

local function is_maple_buf(buf)
  local ok, maple_window = pcall(require, "maple.ui.window")
  return ok and maple_window.get_buf() == buf
end

local function is_normal_buf(buf)
  return vim.bo[buf].buftype == ""
end

local function is_sidekick_buf(buf)
  return vim.bo[buf].filetype == vim.g.sidekick_buf_filetype
end

local augroup = vim.api.nvim_create_augroup("SwitchInputSource", { clear = true })

vim.api.nvim_create_autocmd("InsertLeave", {
  group = augroup,
  pattern = "*",
  desc = "Save input source and switch to English",
  callback = function()
    save_source_and_switch_to_english()
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = augroup,
  pattern = "*",
  desc = "Restore saved input source",
  callback = function(args)
    local need_restore = is_normal_buf(args.buf) or is_maple_buf(args.buf)

    if need_restore then
      restore_saved_source()
    end
  end,
})

vim.api.nvim_create_autocmd("BufLeave", {
  group = augroup,
  pattern = "*",
  desc = "Save input source and switch to English",
  callback = function(args)
    if is_sidekick_buf(args.buf) then
      save_source_and_switch_to_english()
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  pattern = "*",
  desc = "Restore saved input source",
  callback = function(args)
    if is_sidekick_buf(args.buf) then
      restore_saved_source()
    end
  end,
})
