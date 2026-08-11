-- Keep a narrow window on the left for contextual sidebar views.
local M = {}
M.filetype = "sidebar"

local layout = require("ui.layout")
local tree = require("ui.sidebar.tree")
local SIDEBAR_WIDTHS = layout.sidebar
local DEFAULT_WIDTH = SIDEBAR_WIDTHS[2]
local TREE_WIDTH = SIDEBAR_WIDTHS[3]

local SIDEBAR_MODE = {
  blank = "blank",
  tree = "tree",
}
local SIDEBAR_NAME = {
  [SIDEBAR_MODE.blank] = "",
  [SIDEBAR_MODE.tree] = "Tree",
}
local tree_options = tree.default_options

vim.g.SidebarWidth = vim.g.SidebarWidth or DEFAULT_WIDTH
vim.g.SidebarMode = vim.g.SidebarMode or SIDEBAR_MODE.blank
vim.g.SidebarOpen = vim.g.SidebarOpen == nil and 1 or vim.g.SidebarOpen

local function get_mode()
  return vim.g.SidebarMode
end

local function set_mode(buf, mode)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
  vim.bo[buf].modifiable = false
  tree.clear(buf)
  vim.api.nvim_buf_set_name(buf, SIDEBAR_NAME[mode])
  vim.g.SidebarMode = mode
end

local function find_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == M.filetype then
      return win
    end
  end
end

function M.restore()
  if vim.g.SidebarOpen == 1 then
    M.open()
  end
end

-- sidebar는 폭을 지정해 열면 equalalways가 적용되지 않으므로, 고정 폭을 유지하면서 나머지 창을 수동으로 균등화한다.
local function equalize_editor_windows()
  vim.cmd("wincmd =")
end

local function resize_window(win, width)
  if vim.api.nvim_win_get_width(win) ~= width then
    vim.api.nvim_win_set_width(win, width)
    equalize_editor_windows()
  end
end

local function open_window()
  vim.g.SidebarOpen = 1

  local width = vim.g.SidebarWidth

  local existing = find_window()
  if existing then
    vim.wo[existing].winfixwidth = true
    vim.wo[existing].winfixbuf = true
    if vim.api.nvim_win_get_width(existing) ~= width then
      vim.api.nvim_win_set_width(existing, width)
      equalize_editor_windows()
    end
    return existing, false
  end

  local previous = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = M.filetype
  vim.bo[buf].modifiable = false
  vim.bo[buf].buflisted = false

  vim.cmd("topleft " .. width .. "vsplit")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].winfixwidth = true
  vim.wo[win].winfixbuf = true
  vim.wo[win].statusline = " "
  vim.wo[win].cursorline = false

  equalize_editor_windows()

  -- Restore previous window focus
  vim.api.nvim_set_current_win(previous)
  -- Some startup events can focus the new split after this function returns.
  vim.schedule(function()
    if vim.api.nvim_win_is_valid(previous) then
      vim.api.nvim_set_current_win(previous)
    end
  end)

  return win, true
end

function M.open()
  local win, created = open_window()
  if created and get_mode() == SIDEBAR_MODE.tree then
    M.open_tree(tree_options)
  end

  return win
end

function M.close()
  vim.g.SidebarOpen = 0

  local sidebar = find_window()
  if not sidebar then
    return
  end

  -- Neovim cannot close the last window in a tab.
  if #vim.api.nvim_tabpage_list_wins(0) == 1 then
    vim.api.nvim_set_current_win(sidebar)
    vim.cmd("belowright new")
  end

  local buf = vim.api.nvim_win_get_buf(sidebar)
  tree.clear(buf)
  vim.api.nvim_win_close(sidebar, true)
  equalize_editor_windows()
end

function M.toggle()
  if find_window() then
    M.close()
  else
    M.open()
  end
end

local function set_width(width)
  vim.g.SidebarWidth = width

  local sidebar = find_window()
  if sidebar then
    resize_window(sidebar, width)
  end

  return width
end

function M.focus_tree()
  local win = find_window()
  if win and get_mode() == SIDEBAR_MODE.tree then
    vim.api.nvim_set_current_win(win)
  end
end

function M.focus_tree_file(file)
  local win = find_window()
  if not win or get_mode() ~= SIDEBAR_MODE.tree then
    return
  end
  tree.focus_file(win, file)
end

function M.open_tree(opts)
  opts = opts or tree_options
  tree_options = opts

  local target_win = vim.api.nvim_get_current_win()
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file ~= "" then
    current_file = vim.fs.normalize(current_file)
  end
  local cwd = vim.fn.getcwd()

  local win = open_window()
  local buf = vim.api.nvim_win_get_buf(win)
  set_mode(buf, SIDEBAR_MODE.tree)
  resize_window(win, TREE_WIDTH)

  tree.render({
    win = win,
    buf = buf,
    opts = opts,
    cwd = cwd,
    target_win = target_win,
    current_file = current_file,
    close = M.close_tree,
  })
end

function M.close_tree()
  local sidebar = find_window()
  if not sidebar then
    return
  end

  local buf = vim.api.nvim_win_get_buf(sidebar)
  if get_mode() ~= SIDEBAR_MODE.tree then
    return
  end

  set_mode(buf, SIDEBAR_MODE.blank)
  resize_window(sidebar, vim.g.SidebarWidth)
end

function M.toggle_tree(opts)
  local sidebar = find_window()
  if sidebar and get_mode() == SIDEBAR_MODE.tree then
    tree.focus_target(sidebar)
    M.close_tree()
  else
    M.open_tree(opts)
    vim.schedule(M.focus_tree)
  end
end

function M.setup()
  tree.setup({
    sidebar_filetype = M.filetype,
    focus_file = M.focus_tree_file,
  })

  vim.keymap.set("n", "<leader>bb", M.toggle, { desc = "Toggle sidebar" })

  for index, width in ipairs(SIDEBAR_WIDTHS) do
    vim.keymap.set("n", "<leader>b" .. index, function()
      set_width(width)
    end, { desc = ("Set sidebar width to %d"):format(width) })
  end

  vim.keymap.set("n", "<leader>pt", function()
    M.toggle_tree(tree.default_options)
  end, { desc = "Toggle project tree" })
end

return M
