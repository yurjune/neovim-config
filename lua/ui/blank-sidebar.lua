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

  vim.cmd("topleft " .. M.width .. "vsplit")
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

function M.open_tree(opts)
  opts = opts or {}
  local buf = vim.api.nvim_win_get_buf(M.open())
  local namespace = vim.api.nvim_create_namespace("blank-sidebar-project-tree")

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
    vim.api.nvim_set_hl(0, "BlankSidebarDirectory", {
      fg = "#94e2d5",
      bold = true,
    })
    vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
    for row, columns in pairs(ranges) do
      vim.api.nvim_buf_set_extmark(buf, namespace, row - 1, columns[1], {
        end_col = columns[2],
        hl_group = "BlankSidebarDirectory",
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
  vim.b[buf].tree_visible = true
end

function M.close_tree()
  local sidebar = find_window()
  if not sidebar then
    return
  end

  local buf = vim.api.nvim_win_get_buf(sidebar)
  local namespace = vim.api.nvim_create_namespace("blank-sidebar-project-tree")
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
  vim.b[buf].tree_visible = false
end

function M.toggle_tree(opts)
  local sidebar = find_window()
  if sidebar and vim.b[vim.api.nvim_win_get_buf(sidebar)].tree_visible then
    M.close_tree()
  else
    M.open_tree(opts)
  end
end

function M.setup()
  vim.keymap.set("n", "<leader>bb", M.toggle, { desc = "Toggle blank sidebar" })

  vim.keymap.set("n", "<leader>pt", function()
    M.toggle_tree({
      hidden = true,
      filter = {
        ".next",
        "node_modules",
        ".git",
      },
    })
  end, { desc = "Toggle project tree" })
end

return M
