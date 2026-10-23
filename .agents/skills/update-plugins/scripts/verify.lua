-- Headless verification harness for the update-plugins skill.
-- Does what a plain headless startup skips: force-loads every plugin, fires VeryLazy, compiles Tree-sitter queries.
-- Records errors and warnings by phase and writes them as JSON to $VERIFY_OUT.
-- Given $VERIFY_BASELINE, drops issues already in that file and fails only when new ones remain.
--
--   VERIFY_OUT=<path> [VERIFY_BASELINE=<path>] nvim --headless -c "luafile <this file>" 2><log>

local out_path = assert(vim.env.VERIFY_OUT, "VERIFY_OUT is not set")
local baseline_path = vim.env.VERIFY_BASELINE

local issues = {}
local phase = "startup"

-- Writes the phase to stderr so a hang shows where it stopped.
local function set_phase(name)
  phase = name
  io.stderr:write("verify: " .. name .. "\n")
end

local function record(source, level, msg)
  msg = vim.trim(tostring(msg))
  if msg ~= "" then
    table.insert(issues, { phase = phase, source = source, level = level, msg = msg })
  end
end

-- Plugins such as noice replace vim.notify when they load, so the hook is reinstalled every phase.
-- The original function is not called: in headless mode it prints to :messages and would be counted twice.
local hooked
local function hook_notify()
  if vim.notify == hooked then
    return
  end
  hooked = function(msg, level)
    level = level or vim.log.levels.INFO
    if level >= vim.log.levels.WARN then
      record("notify", level >= vim.log.levels.ERROR and "error" or "warn", msg)
    end
  end
  vim.notify = hooked
end

-- Errors from autocmds and scheduled callbacks only reach :messages, so new lines are read every phase.
local seen_messages = 0
local function collect_messages()
  local lines = vim.split(vim.api.nvim_exec2("messages", { output = true }).output, "\n", { trimempty = true })
  for i = seen_messages + 1, #lines do
    record("messages", "message", lines[i])
  end
  seen_messages = #lines
end

-- Waits for scheduled callbacks to run, then collects what they reported.
local function settle(ms)
  vim.wait(ms, function()
    return false
  end)
  collect_messages()
  hook_notify()
end

local function load_plugins()
  local plugins = require("lazy").plugins()
  table.sort(plugins, function(a, b)
    return a.name < b.name
  end)
  for _, plugin in ipairs(plugins) do
    if not plugin._.loaded and plugin._.cond ~= false then
      set_phase("load:" .. plugin.name)
      local ok, err = pcall(require("lazy").load, { plugins = { plugin.name } })
      if not ok then
        record("load", "error", err)
      end
      settle(20)
    end
  end
end

local function fire_very_lazy()
  set_phase("VeryLazy")
  local ok, err = pcall(vim.api.nvim_exec_autocmds, "User", { pattern = "VeryLazy", modeline = false })
  if not ok then
    record("autocmd", "error", err)
  end
  settle(200)
end

-- Compiles every runtimepath query for languages with a parser, including custom ones in queries/ and after/queries/.
local function compile_queries()
  set_phase("queries")
  local query_langs_with_parser = {}
  for _, file in ipairs(vim.api.nvim_get_runtime_file("parser/*.so", true)) do
    local lang = vim.fn.fnamemodify(file, ":t:r")
    local ok, err = pcall(vim.treesitter.language.add, lang)
    if ok then
      query_langs_with_parser[lang] = true
    else
      record("parser", "error", lang .. ": " .. err)
    end
  end

  local pairs_seen = {}
  for _, file in ipairs(vim.api.nvim_get_runtime_file("queries/*/*.scm", true)) do
    local lang = vim.fn.fnamemodify(file, ":h:t")
    local name = vim.fn.fnamemodify(file, ":t:r")
    local key = lang .. "/" .. name
    if query_langs_with_parser[lang] and not pairs_seen[key] then
      pairs_seen[key] = true
      local ok, err = pcall(vim.treesitter.query.get, lang, name)
      if not ok then
        record("query", "error", key .. ": " .. err)
      end
    end
  end
  settle(0)
end

-- Checks that the user commands keymaps call exist.
-- Loading and setup() still succeed when a plugin removes or renames a command, so only this catches it.
local function check_keymap_commands()
  set_phase("commands")
  local seen = {}
  for _, mode in ipairs({ "n", "x", "s", "o", "i", "c", "t" }) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      local rhs = map.rhs or ""
      local cmd = rhs:match("^<[Cc][Mm][Dd]>(%u[%w_]*)") or rhs:match("^:(%u[%w_]*)")
      -- exists() returns 0 when missing and 3 when ambiguous across several commands.
      if cmd and not seen[cmd] and vim.fn.exists(":" .. cmd) % 3 == 0 then
        seen[cmd] = true
        record("keymap", "error", ("%s: command :%s does not exist"):format(map.lhs, cmd))
      end
    end
  end
  settle(0)
end

local function read_baseline()
  if not baseline_path then
    return nil
  end
  local file = assert(io.open(baseline_path, "r"), "cannot read VERIFY_BASELINE: " .. baseline_path)
  local baseline = vim.json.decode(file:read("*a"))
  file:close()
  local keys = {}
  for _, issue in ipairs(baseline.issues) do
    keys[issue.phase .. "\0" .. issue.msg] = true
  end
  return keys
end

local function finish()
  local result = { issues = issues }
  local baseline = read_baseline()
  if baseline then
    result.new = vim.tbl_filter(function(issue)
      return not baseline[issue.phase .. "\0" .. issue.msg]
    end, issues)
  end

  local file = assert(io.open(out_path, "w"))
  file:write(vim.json.encode(result))
  file:close()

  local summary = ("verify: %d issues"):format(#issues)
  if result.new then
    summary = summary .. (", %d new"):format(#result.new)
  end
  io.stdout:write(summary .. " -> " .. out_path .. "\n")
  vim.cmd(result.new and #result.new > 0 and "cquit 1" or "qall!")
end

local function run()
  hook_notify()
  collect_messages()
  load_plugins()
  fire_very_lazy()
  compile_queries()
  check_keymap_commands()
  set_phase("late")
  settle(1000)
  finish()
end

-- `-c` runs before VimEnter, so start after VimEnter, once the startup autocmds have finished.
-- Notifications setup() scheduled during startup run before run(), so hook in right at VimEnter.
if vim.v.vim_did_enter == 1 then
  vim.schedule(run)
else
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      hook_notify()
      vim.schedule(run)
    end,
  })
end
