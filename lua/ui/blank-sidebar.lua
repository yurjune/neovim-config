-- Keep a narrow, empty window on the left as a visual sidebar.
local M = {}

M.width = 42
M.filetype = "blank-sidebar"

local function find_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == M.filetype then
      return win
    end
  end
end

function M.open()
  local existing = find_window()
  if existing then
    return existing
  end

  local previous = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = M.filetype
  vim.bo[buf].modifiable = false
  vim.bo[buf].buflisted = false

  local win = vim.api.nvim_open_win(buf, false, {
    split = "left",
    win = previous,
    width = M.width,
  })

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].winfixwidth = true
  vim.wo[win].statusline = " "
  vim.wo[win].cursorline = false

  -- Restore previous window focus
  vim.api.nvim_set_current_win(previous)
  -- Some startup events can focus the new split after this function returns.
  vim.schedule(function()
    if vim.api.nvim_win_is_valid(previous) then
      vim.api.nvim_set_current_win(previous)
    end
  end)

  return win
end

function M.close()
  local sidebar = find_window()
  if not sidebar then
    return
  end

  -- Neovim cannot close the last window in a tab.
  if #vim.api.nvim_tabpage_list_wins(0) == 1 then
    vim.api.nvim_set_current_win(sidebar)
    vim.cmd("belowright new")
  end

  vim.api.nvim_win_close(sidebar, true)
end

function M.toggle()
  if find_window() then
    M.close()
  else
    M.open()
  end
end

function M.setup()
  vim.keymap.set("n", "<leader>bb", M.toggle, { desc = "Toggle blank sidebar" })
end

return M
