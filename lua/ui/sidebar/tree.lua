local M = {}
local files = require("ui.sidebar.files")

local TREE_NAMESPACE = vim.api.nvim_create_namespace("sidebar")
local CURRENT_FILE_NAMESPACE = vim.api.nvim_create_namespace("sidebar-current-file")
local CURSOR_NAMESPACE = vim.api.nvim_create_namespace("sidebar-tree-cursor")
local states = {}

local function set_highlights()
  vim.api.nvim_set_hl(0, "SidebarCursorName", {
    fg = "#1e1e2e",
    bg = "#cba6f7",
    bold = true,
  })
  vim.api.nvim_set_hl(0, "SidebarDirectory", {
    fg = "#94e2d5",
    bold = true,
  })
  vim.api.nvim_set_hl(0, "SidebarCurrentFile", {
    fg = "#1e1e2e",
    bg = "#fef3c7",
    bold = true,
  })
end

local function highlight_directories(buf, names)
  vim.api.nvim_buf_clear_namespace(buf, TREE_NAMESPACE, 0, -1)

  for row, name in pairs(names) do
    if name.is_directory then
      vim.api.nvim_buf_set_extmark(buf, TREE_NAMESPACE, row - 1, name.start_col, {
        end_col = name.end_col,
        hl_group = "SidebarDirectory",
        priority = 100,
      })
    end
  end
end

local function highlight_name(buf, row, namespace, group, priority)
  local name = states[buf].snapshot.names[row]
  if not name then
    vim.api.nvim_buf_del_extmark(buf, namespace, 1)
    return
  end
  vim.api.nvim_buf_set_extmark(buf, namespace, row - 1, name.start_col, {
    id = 1,
    end_col = name.end_col,
    hl_group = group,
    priority = priority,
  })
  return name
end

local function highlight_cursor(buf)
  if buf == vim.api.nvim_get_current_buf() and states[buf] then
    local row = vim.api.nvim_win_get_cursor(0)[1]
    highlight_name(buf, row, CURSOR_NAMESPACE, "SidebarCursorName", 150)
  end
end

local function reveal_row(win, row, col, leftcol)
  if not row then
    return
  end

  vim.api.nvim_win_set_cursor(win, { row, col or 0 })
  vim.api.nvim_win_call(win, function()
    vim.cmd("normal! zz")
    local view = vim.fn.winsaveview()
    view.leftcol = leftcol or 0
    vim.fn.winrestview(view)
  end)
end

function M.clear(buf)
  vim.api.nvim_buf_clear_namespace(buf, CURSOR_NAMESPACE, 0, -1)
  vim.api.nvim_buf_clear_namespace(buf, TREE_NAMESPACE, 0, -1)
  vim.api.nvim_buf_clear_namespace(buf, CURRENT_FILE_NAMESPACE, 0, -1)
  states[buf] = nil
end

function M.focus_file(win, file)
  file = file or vim.api.nvim_buf_get_name(0)

  if not win or not vim.api.nvim_win_is_valid(win) then
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local state = states[buf]
  if not state then
    return
  end

  local current_file = file ~= "" and vim.fs.normalize(file) or ""
  local row = state.snapshot.rows[current_file]
  local file_col = 0
  local leftcol = 0

  local name = highlight_name(buf, row, CURRENT_FILE_NAMESPACE, "SidebarCurrentFile", 200)
  if name then
    file_col = name.start_col
    local filename_end = vim.fn.strdisplaywidth(state.snapshot.output[row]:sub(1, name.end_col))
    leftcol = math.max(0, filename_end - vim.api.nvim_win_get_width(win))
  end
  reveal_row(win, row, file_col, leftcol)
end

function M.focus_target(win)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return
  end

  local state = states[vim.api.nvim_win_get_buf(win)]
  if state and vim.api.nvim_win_is_valid(state.target_win) then
    vim.api.nvim_set_current_win(state.target_win)
  end
end

function M.open_file(win, stay_in_tree)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local state = states[buf]
  if not state then
    return
  end

  local row = vim.api.nvim_win_get_cursor(win)[1]
  local path = state.snapshot.paths[row]
  if not path then
    return
  end

  path = vim.fs.normalize(vim.fs.joinpath(state.snapshot.cwd, path))
  if vim.fn.isdirectory(path) == 1 then
    return
  end
  if not vim.api.nvim_win_is_valid(state.target_win) then
    vim.notify("The tree's target window is no longer available", vim.log.levels.WARN, { title = "Sidebar" })
    return
  end

  local function edit()
    vim.api.nvim_cmd({ cmd = "edit", args = { path } }, {})
  end

  if stay_in_tree then
    -- Borrow the target window instead of entering it: `:edit` behaves the same,
    -- but no window ever changes, so WinEnter and WinLeave stay quiet.
    vim.api.nvim_win_call(state.target_win, edit)
  else
    vim.api.nvim_set_current_win(state.target_win)
    edit()
  end

  return true
end

function M.navigate_file(win, direction)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local state = states[buf]
  if not state then
    return
  end

  local stay_in_tree = vim.api.nvim_get_current_win() == win
  local row
  if stay_in_tree then
    row = vim.api.nvim_win_get_cursor(win)[1]
  else
    row = state.snapshot.rows[vim.fs.normalize(vim.api.nvim_buf_get_name(0))]
  end
  local path, next_row = files.adjacent(state.snapshot, row, direction)
  if path then
    reveal_row(win, next_row)
    return M.open_file(win, stay_in_tree)
  end
end

function M.render(args)
  local snapshot = files.get(args.opts, args.cwd, true)
  states[args.buf] = {
    snapshot = snapshot,
    target_win = args.target_win,
  }

  vim.bo[args.buf].modifiable = true
  vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, snapshot.output)
  vim.bo[args.buf].modifiable = false

  highlight_directories(args.buf, snapshot.names)
  M.focus_file(args.win, args.current_file)
  highlight_cursor(args.buf)
end

function M.refresh(win, opts)
  local buf = vim.api.nvim_win_get_buf(win)
  local state = states[buf]
  if not state then
    return
  end

  local current_file = ""
  if vim.api.nvim_win_is_valid(state.target_win) then
    current_file = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(state.target_win))
  end

  M.render({
    win = win,
    buf = buf,
    opts = opts,
    cwd = vim.fn.getcwd(),
    target_win = state.target_win,
    current_file = current_file,
  })
  vim.notify("Tree refreshed", vim.log.levels.INFO, { title = "Sidebar", timeout = 1000 })
end

function M.setup(opts)
  local group = vim.api.nvim_create_augroup("sidebar-tree", { clear = true })

  set_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_highlights })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = opts.sidebar_filetype,
    desc = "Set up sidebar tree navigation and cursor highlighting",
    group = group,
    callback = function(args)
      vim.api.nvim_create_autocmd({ "WinEnter", "CursorMoved", "WinLeave" }, {
        group = group,
        buffer = args.buf,
        desc = "Highlight the name under the cursor in the focused tree",
        callback = function(event)
          if event.event == "WinLeave" then
            vim.api.nvim_buf_clear_namespace(event.buf, CURSOR_NAMESPACE, 0, -1)
          else
            highlight_cursor(event.buf)
          end
        end,
      })

      vim.keymap.set("n", "<CR>", function()
        M.open_file(vim.api.nvim_get_current_win())
      end, {
        buffer = args.buf,
        desc = "Open tree file",
      })

      vim.keymap.set("n", "<Tab>", function()
        M.open_file(vim.api.nvim_get_current_win(), true)
      end, {
        buffer = args.buf,
        desc = "Open tree file and stay in tree",
      })

      vim.keymap.set("n", "<Esc>", opts.close, {
        buffer = args.buf,
        desc = "Close tree",
      })
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Track the current file in the sidebar tree",
    group = group,
    callback = function(args)
      if vim.bo[args.buf].filetype ~= opts.sidebar_filetype then
        opts.focus_file(vim.api.nvim_buf_get_name(args.buf))
      end
    end,
  })
end

return M
