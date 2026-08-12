-- Keep a narrow window on the left for contextual sidebar views.
local M = {}
M.filetype = "sidebar"

local SIDEBAR_WIDTHS = { 21, 42, 63 }
local DEFAULT_WIDTH = 42
local SIDEBAR_MODE = {
  blank = "blank",
  tree = "tree",
}
local SIDEBAR_NAMESPACE = vim.api.nvim_create_namespace("sidebar")
local DEFAULT_TREE_OPTIONS = {
  hidden = true,
  filter = {
    ".next",
    "node_modules",
    ".git",
    ".pnpm-store",
  },
}
local tree_options = DEFAULT_TREE_OPTIONS

vim.g.SidebarWidth = vim.g.SidebarWidth or DEFAULT_WIDTH
vim.g.SidebarMode = vim.g.SidebarMode or SIDEBAR_MODE.blank

local function get_mode()
  return vim.g.SidebarMode
end

local function set_mode(buf, mode)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, SIDEBAR_NAMESPACE, 0, -1)
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

local function open_window()
  local width = vim.g.SidebarWidth

  local existing = find_window()
  if existing then
    if vim.api.nvim_win_get_width(existing) ~= width then
      vim.api.nvim_win_set_width(existing, width)
      vim.cmd("wincmd =")
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

local function set_width(width)
  vim.g.SidebarWidth = width

  local sidebar = find_window()
  if sidebar then
    vim.api.nvim_win_set_width(sidebar, width)
    vim.cmd("wincmd =")
  end

  return width
end

function M.decrease_width()
  local current = vim.g.SidebarWidth
  local width = SIDEBAR_WIDTHS[1]

  for index = #SIDEBAR_WIDTHS, 1, -1 do
    if SIDEBAR_WIDTHS[index] < current then
      width = SIDEBAR_WIDTHS[index]
      break
    end
  end

  return set_width(width)
end

function M.increase_width()
  local current = vim.g.SidebarWidth
  local width = SIDEBAR_WIDTHS[#SIDEBAR_WIDTHS]

  for _, candidate in ipairs(SIDEBAR_WIDTHS) do
    if candidate > current then
      width = candidate
      break
    end
  end

  return set_width(width)
end

function M.open_tree(opts)
  opts = opts or tree_options
  tree_options = opts

  local win = open_window()
  local buf = vim.api.nvim_win_get_buf(win)
  set_mode(buf, SIDEBAR_MODE.tree)

  local command = {
    "env",
    "LS_COLORS=di=1",
    "tree",
    "-C",
  }

  if opts.depth then
    vim.list_extend(command, { "-L", tostring(opts.depth) })
  end
  if opts.hidden then
    table.insert(command, "-a")
  end
  if opts.filter and #opts.filter > 0 then
    vim.list_extend(command, { "-I", table.concat(opts.filter, "|") })
  end

  local output = vim.fn.systemlist(command)
  local function parse_directory_line(line)
    -- `tree -C` wraps directory names with ANSI color codes.
    local prefix, name, suffix = line:match("^(.-)\27%[[%d;]*m(.-)\27%[[%d;]*m(.*)$")
    if not name then
      return line
    end

    return prefix .. name .. suffix, { #prefix, #prefix + #name }
  end

  local function highlight_directories(ranges)
    vim.api.nvim_set_hl(0, "SidebarDirectory", {
      fg = "#94e2d5",
      bold = true,
    })
    vim.api.nvim_buf_clear_namespace(buf, SIDEBAR_NAMESPACE, 0, -1)
    for row, columns in pairs(ranges) do
      vim.api.nvim_buf_set_extmark(buf, SIDEBAR_NAMESPACE, row - 1, columns[1], {
        end_col = columns[2],
        hl_group = "SidebarDirectory",
      })
    end
  end

  local directory_ranges = {}
  for row, line in ipairs(output) do
    output[row], directory_ranges[row] = parse_directory_line(line)
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
  vim.bo[buf].modifiable = false
  highlight_directories(directory_ranges)
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
end

function M.toggle_tree(opts)
  local sidebar = find_window()
  if sidebar and get_mode() == SIDEBAR_MODE.tree then
    M.close_tree()
  else
    M.open_tree(opts)
  end
end

function M.setup()
  vim.keymap.set("n", "<leader>bb", M.toggle, { desc = "Toggle sidebar" })
  vim.keymap.set("n", "<leader>bq", M.decrease_width, { desc = "Decrease sidebar width" })
  vim.keymap.set("n", "<leader>bw", M.increase_width, { desc = "Increase sidebar width" })

  vim.keymap.set("n", "<leader>pt", function()
    M.toggle_tree(DEFAULT_TREE_OPTIONS)
  end, { desc = "Toggle project tree" })
end

return M
