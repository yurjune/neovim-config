local M = {}
local file_visibility = require("etc.file-visibility")

M.default_options = {
  compress = 2,
  hidden = true,
  ignore_file = file_visibility.ignore_file,
}

local cached
local cached_options

local function build_file_command(opts)
  local command = { "fd", "--color=never", "--no-ignore", "--type", "f", "--type", "d", "--type", "l" }
  if opts.hidden then
    table.insert(command, "--hidden")
  end
  if opts.ignore_file then
    vim.list_extend(command, { "--ignore-file", opts.ignore_file })
  end
  return command
end

local function build_command(opts, output_options)
  local command = {
    "env",
    "LS_COLORS=di=1",
    "tree",
    "--fromfile",
    "--fflinks",
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
  if opts.filter and #opts.filter > 0 then
    vim.list_extend(command, { "-I", table.concat(opts.filter, "|") })
  end

  return command
end

-- `tree -C -f` colours directory names and prints full paths, yielding both
-- the rendered line and the path that line points to.
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

local function run(command, cwd, input)
  local result = vim.system(command, { cwd = cwd, stdin = input, text = true }):wait()
  if result.code ~= 0 then
    error(("Sidebar file discovery failed (%s): %s"):format(command[1], result.stderr or ""))
  end
  local lines = vim.split(result.stdout, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines)
  end
  return lines
end

local function read(opts, cwd)
  local entries = run(build_file_command(opts), cwd)
  -- tree --fromfile reports an error for empty input.
  if #entries == 0 then
    return { ".", "", "0 directories, 0 files" }, { "." }, { { 0, 1 } }
  end
  for index, path in ipairs(entries) do
    local target = vim.uv.fs_readlink(vim.fs.joinpath(cwd, path))
    if target then
      entries[index] = path .. " -> " .. target
    end
  end
  local lines = run(build_command(opts, { "-C", "-f" }), cwd, table.concat(entries, "\n") .. "\n")
  local output, paths, directory_ranges = {}, {}, {}

  for row, line in ipairs(lines) do
    output[row], paths[row], directory_ranges[row] = parse_line(line)
  end

  return output, paths, directory_ranges
end

-- Rendering and navigation share the same absolute-path index.
local function index_rows(paths, cwd)
  local rows = {}

  for row, path in ipairs(paths) do
    rows[vim.fs.normalize(vim.fs.joinpath(cwd, path))] = row
  end

  return rows
end

function M.invalidate()
  cached = nil
  cached_options = nil
end

function M.get(opts, cwd, refresh)
  if not refresh and cached and cached.cwd == cwd and vim.deep_equal(cached_options, opts) then
    return cached
  end

  local output, paths, directory_ranges = read(opts, cwd)
  cached = {
    output = output,
    paths = paths,
    rows = index_rows(paths, cwd),
    directory_ranges = directory_ranges,
    cwd = cwd,
  }
  cached_options = vim.deepcopy(opts)
  return cached
end

function M.adjacent(snapshot, row, direction)
  if not row then
    return
  end

  local last_row = direction == 1 and #snapshot.output or 1
  for next_row = row + direction, last_row, direction do
    local path = snapshot.paths[next_row]
    if path then
      local absolute_path = vim.fs.normalize(vim.fs.joinpath(snapshot.cwd, path))
      local stat = vim.uv.fs_stat(absolute_path)
      if stat and stat.type == "file" then
        return absolute_path, next_row
      end
    end
  end
end

return M
