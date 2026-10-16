-- Applies the shared visibility rules to Oil's hidden-entry callback.
local M = {}
local file_visibility = require("etc.file-visibility")

local rules = {}

local function name_pattern(glob)
  return "^"
    .. glob:gsub(".", function(char)
      if char == "*" then
        return ".*"
      elseif char == "?" then
        return "."
      end
      return char:gsub("(%W)", "%%%1")
    end)
    .. "$"
end

for _, line in ipairs(vim.fn.readfile(file_visibility.ignore_file)) do
  local glob = vim.trim(line)
  if glob ~= "" and glob:sub(1, 1) ~= "#" then
    local negation, name, slash = glob:match("^(!?)(.-)(/?)$")
    -- Shared rules use entry names, not paths or full gitignore syntax.
    assert(name ~= "" and not name:find("[/\\%[%]]"), "Unsupported file visibility rule: " .. line)
    rules[#rules + 1] = {
      pattern = name_pattern(name),
      directory_only = slash == "/",
      hidden = negation ~= "!",
    }
  end
end

function M.is_hidden_file(name, bufnr)
  local is_directory
  -- The last matching rule wins.
  for i = #rules, 1, -1 do
    local rule = rules[i]
    if name:match(rule.pattern) then
      if rule.directory_only and is_directory == nil then
        local directory = require("oil").get_current_dir(bufnr)
        is_directory = directory ~= nil and vim.fn.isdirectory(vim.fs.joinpath(directory, name)) == 1
      end
      if not rule.directory_only or is_directory then
        return rule.hidden
      end
    end
  end
  return false
end

return M
