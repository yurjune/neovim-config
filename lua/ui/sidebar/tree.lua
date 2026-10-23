local M = {}
local file_visibility = require("etc.file-visibility")

M.default_options = {
  compress = 2,
  hidden = true,
  -- tree's --gitfile reads this file using .gitignore syntax.
  ignore_file = file_visibility.ignore_file,
}

local TREE_NAMESPACE = vim.api.nvim_create_namespace("sidebar")
local CURRENT_FILE_NAMESPACE = vim.api.nvim_create_namespace("sidebar-current-file")
local states = {}

local function build_command(opts, output_options)
  local command = {
    "env",
    "LS_COLORS=di=1",
    "tree",
  }
  vim.list_extend(command, output_options)

  if opts.compress then
    vim.list_extend(command, { "--compress", tostring(opts.compress) })
  end
  if opts.depth then
    vim.list_extend(command, { "-L", tostring(opts.depth) })
  end
  if opts.hidden then
    table.insert(command, "-a")
  end
  if opts.ignore_file then
    table.insert(command, "--gitfile=" .. opts.ignore_file)
  end
  if opts.filter and #opts.filter > 0 then
    vim.list_extend(command, { "-I", table.concat(opts.filter, "|") })
  end

  return command
end

-- `tree -C -f` colours directory names and prints full paths, so a single call
-- yields both the rendered line and the path that line points to.
local function parse_line(line)
  local plain = line:gsub("\27%[[%d;]*m", "")
  local path = plain == "." and "." or plain:match("^[^.]*(%./.*)$")
  if not path then
    -- Blank and report lines carry no entry.
    return plain
  end

  local prefix = plain:sub(1, #plain - #path)
  -- Symlinks are printed as `path -> target`; only the path side is openable.
  local link = path:match("( %-> .*)$") or ""
  path = path:sub(1, #path - #link)
  local name = (path == "." and "." or vim.fs.basename(path)) .. link
  local is_directory = plain ~= line

  return prefix .. name, path, is_directory and { #prefix, #prefix + #name - #link } or nil
end

local function read(opts)
  local lines = vim.fn.systemlist(build_command(opts, { "-C", "-f" }))
  local output, paths, directory_ranges = {}, {}, {}

  for row, line in ipairs(lines) do
    output[row], paths[row], directory_ranges[row] = parse_line(line)
  end

  return output, paths, directory_ranges
end

-- Every buffer switch looks up a row, so pay for the paths once while rendering.
local function index_rows(paths, cwd)
  local rows = {}

  for row, path in ipairs(paths) do
    rows[vim.fs.normalize(vim.fs.joinpath(cwd, path))] = row
  end

  return rows
end

local function highlight_directories(buf, directory_ranges)
  vim.api.nvim_set_hl(0, "SidebarDirectory", {
    fg = "#94e2d5",
    bold = true,
  })
  vim.api.nvim_set_hl(0, "SidebarCurrentFile", {
    fg = "#1e1e2e",
    bg = "#fef3c7",
    bold = true,
  })
  vim.api.nvim_buf_clear_namespace(buf, TREE_NAMESPACE, 0, -1)

  for row, columns in pairs(directory_ranges) do
    vim.api.nvim_buf_set_extmark(buf, TREE_NAMESPACE, row - 1, columns[1], {
      end_col = columns[2],
      hl_group = "SidebarDirectory",
    })
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
  local row = state.rows[current_file]
  local file_col = 0
  local leftcol = 0

  vim.api.nvim_buf_clear_namespace(buf, CURRENT_FILE_NAMESPACE, 0, -1)
  if row then
    local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
    local name = vim.fs.basename(current_file)
    local start_col = line and line:find(name, 1, true)
    if start_col then
      start_col = start_col - 1
      file_col = start_col
      local filename_end = vim.fn.strdisplaywidth(line:sub(1, start_col + #name))
      leftcol = math.max(0, filename_end - vim.api.nvim_win_get_width(win))
      vim.api.nvim_buf_set_extmark(buf, CURRENT_FILE_NAMESPACE, row - 1, start_col, {
        end_col = start_col + #name,
        hl_group = "SidebarCurrentFile",
        priority = 200,
      })
    end
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
  local path = state.paths[row]
  if not path then
    return
  end

  path = vim.fs.normalize(vim.fs.joinpath(state.cwd, path))
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

function M.render(args)
  local output, paths, directory_ranges = read(args.opts)
  states[args.buf] = {
    paths = paths,
    rows = index_rows(paths, args.cwd),
    cwd = args.cwd,
    target_win = args.target_win,
  }

  vim.bo[args.buf].modifiable = true
  vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, output)
  vim.bo[args.buf].modifiable = false

  highlight_directories(args.buf, directory_ranges)
  M.focus_file(args.win, args.current_file)
end

function M.setup(opts)
  local group = vim.api.nvim_create_augroup("sidebar-tree", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = opts.sidebar_filetype,
    desc = "Set sidebar tree keymaps",
    group = group,
    callback = function(args)
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
