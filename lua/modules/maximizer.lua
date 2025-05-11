-- For maximize and restore window
local M = {}
local size = nil

function M.maximize()
  size = vim.fn.winrestcmd()
  vim.cmd("vertical resize")
  vim.cmd("resize")
  vim.cmd("normal! ze")
end

function M.restore()
  if size ~= nil then
    vim.cmd(size)
    if size ~= vim.fn.winrestcmd() then
      vim.cmd("wincmd =")
    end
    size = nil
    vim.cmd("normal! ze")
  end
end

function M.toggle()
  if size ~= nil then
    M.restore()
  elseif vim.fn.winnr("$") > 1 then
    M.maximize()
  end
end

function M.increase_width(amount)
  vim.cmd("vertical resize +" .. amount)
end

function M.decrease_width(amount)
  vim.cmd("vertical resize -" .. amount)
end

vim.keymap.set({ "n", "v" }, "<leader>wm", M.toggle, { desc = "Maximize window" })

vim.keymap.set({ "n", "v" }, "<leader>wi", function()
  M.increase_width(20)
end, { desc = "Increase window with 20" })

vim.keymap.set({ "n", "v" }, "<leader>wd", function()
  M.decrease_width(20)
end, { desc = "Decrease window with 20" })

return M
