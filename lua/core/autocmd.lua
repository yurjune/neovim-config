vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- option for remove continue commenting when line changes
    -- r: continue commenting when line changed by enter
    -- o: continue commenting when line changed by o or O command
    vim.opt_local.formatoptions:append({ "r", "o" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Keep equalalways disabled so fixed-width side windows are preserved.
-- Re-equalize the remaining editor windows after layout changes.
vim.opt.equalalways = false
vim.api.nvim_create_autocmd({ "WinNew", "WinClosed" }, {
  desc = "Equalize editor windows after layout changes",
  group = vim.api.nvim_create_augroup("window-layout", { clear = true }),
  callback = function()
    vim.schedule(function()
      local current = vim.api.nvim_get_current_win()
      vim.cmd("wincmd =")
      if vim.api.nvim_win_is_valid(current) then
        vim.api.nvim_set_current_win(current)
      end
    end)
  end,
})
