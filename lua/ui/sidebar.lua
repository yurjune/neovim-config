-- Keep a narrow window on the left for contextual sidebar views.
local M = {}
M.filetype = "sidebar"

local layout = require("ui.layout")
local SIDEBAR_WIDTHS = layout.sidebar
local DEFAULT_WIDTH = SIDEBAR_WIDTHS[2]

local SIDEBAR_MODE = {
  blank = "blank",
  tree = "tree",
}
local SIDEBAR_NAME = {
  [SIDEBAR_MODE.blank] = "",
  [SIDEBAR_MODE.tree] = "Tree",
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

-- sidebar는 폭을 지정해 열면 equalalways가 적용되지 않으므로, 고정 폭을 유지하면서 나머지 창을 수동으로 균등화한다.
local function equalize_editor_windows()
  vim.cmd("wincmd =")
end

local function open_window()
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
    vim.api.nvim_win_set_width(sidebar, width)
    equalize_editor_windows()
  end

  return width
end

local function build_tree_command(opts, output_options)
  local command = {
    "env",
    "LS_COLORS=di=1",
    "tree",
  }
  vim.list_extend(command, output_options)

  if opts.depth then
    vim.list_extend(command, { "-L", tostring(opts.depth) })
  end
  if opts.hidden then
    table.insert(command, "-a")
  end
  if opts.filter and #opts.filter > 0 then
    vim.list_extend(command, { "-I", table.concat(opts.filter, "|") })
  end

  return command
end

local function parse_directory_line(line)
  -- `tree -C` wraps directory names with ANSI color codes.
  local prefix, name, suffix = line:match("^(.-)\27%[[%d;]*m(.-)\27%[[%d;]*m(.*)$")
  if not name then
    return line
  end

  return prefix .. name .. suffix, { #prefix, #prefix + #name }
end

local function read_tree(opts)
  local output = vim.fn.systemlist(build_tree_command(opts, { "-C" }))
  local paths = vim.fn.systemlist(build_tree_command(opts, { "-fi", "--noreport" }))
  local directory_ranges = {}

  for row, line in ipairs(output) do
    output[row], directory_ranges[row] = parse_directory_line(line)
  end

  return output, paths, directory_ranges
end

local function find_current_file_row(paths, current_file, cwd)
  if current_file == "" then
    return
  end

  for row, path in ipairs(paths) do
    if vim.fs.normalize(vim.fs.joinpath(cwd, path)) == current_file then
      return row
    end
  end
end

local function highlight_tree(buf, directory_ranges, current_file_row)
  vim.api.nvim_set_hl(0, "SidebarDirectory", {
    fg = "#94e2d5",
    bold = true,
  })
  vim.api.nvim_set_hl(0, "SidebarCurrentFile", {
    fg = "#1e1e2e",
    bg = "#f9e2af",
    bold = true,
  })
  vim.api.nvim_buf_clear_namespace(buf, SIDEBAR_NAMESPACE, 0, -1)

  for row, columns in pairs(directory_ranges) do
    vim.api.nvim_buf_set_extmark(buf, SIDEBAR_NAMESPACE, row - 1, columns[1], {
      end_col = columns[2],
      hl_group = "SidebarDirectory",
    })
  end
  if current_file_row then
    vim.api.nvim_buf_set_extmark(buf, SIDEBAR_NAMESPACE, current_file_row - 1, 0, {
      line_hl_group = "SidebarCurrentFile",
      priority = 200,
    })
  end
end

function M.open_tree(opts)
  opts = opts or tree_options
  tree_options = opts

  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file ~= "" then
    current_file = vim.fs.normalize(current_file)
  end
  local cwd = vim.fn.getcwd()

  local win = open_window()
  local buf = vim.api.nvim_win_get_buf(win)
  set_mode(buf, SIDEBAR_MODE.tree)

  local output, paths, directory_ranges = read_tree(opts)
  local current_file_row = find_current_file_row(paths, current_file, cwd)

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
  vim.bo[buf].modifiable = false
  highlight_tree(buf, directory_ranges, current_file_row)
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

  for index, width in ipairs(SIDEBAR_WIDTHS) do
    vim.keymap.set("n", "<leader>b" .. index, function()
      set_width(width)
    end, { desc = ("Set sidebar width to %d"):format(width) })
  end

  vim.keymap.set("n", "<leader>pt", function()
    M.toggle_tree(DEFAULT_TREE_OPTIONS)
  end, { desc = "Toggle project tree" })
end

return M
