-- update-plugins 스킬의 headless 검증 하네스.
-- 단순 headless 기동이 건너뛰는 일을 직접 한다: 모든 플러그인 강제 로드, VeryLazy 발생, Tree-sitter 쿼리 컴파일.
-- 에러와 경고를 단계별로 기록해 $VERIFY_OUT에 JSON으로 쓴다.
-- $VERIFY_BASELINE을 주면 그 파일에 이미 있는 문제는 빼고, 새 문제가 있을 때만 실패한다.
--
--   VERIFY_OUT=<path> [VERIFY_BASELINE=<path>] nvim --headless -c "luafile <this file>" 2><log>

local out_path = assert(vim.env.VERIFY_OUT, "VERIFY_OUT is not set")
local baseline_path = vim.env.VERIFY_BASELINE

local issues = {}
local phase = "startup"

-- 실행이 멈추면 어디서 멈췄는지 보이도록 단계를 stderr에 쓴다.
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

-- noice 같은 플러그인이 로드되면서 vim.notify를 바꾸므로, 단계마다 훅을 다시 건다.
-- 원래 함수는 부르지 않는다. headless에서는 :messages로 출력돼 두 번 집계된다.
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

-- autocmd와 예약된 콜백의 에러는 :messages에만 남으므로, 단계마다 새 줄을 읽는다.
local seen_messages = 0
local function collect_messages()
  local lines = vim.split(vim.api.nvim_exec2("messages", { output = true }).output, "\n", { trimempty = true })
  for i = seen_messages + 1, #lines do
    record("messages", "message", lines[i])
  end
  seen_messages = #lines
end

-- 예약된 콜백이 실행되게 기다린 뒤, 그동안 보고된 것을 모은다.
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

-- parser가 있는 언어의 runtimepath 쿼리를 모두 컴파일한다. queries/와 after/queries/의 커스텀 쿼리도 포함된다.
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

-- 키맵이 부르는 사용자 명령이 있는지 확인한다.
-- 플러그인이 명령을 없애거나 이름을 바꿔도 로드와 setup()은 성공하므로 여기서만 드러난다.
local function check_keymap_commands()
  set_phase("commands")
  local seen = {}
  for _, mode in ipairs({ "n", "x", "s", "o", "i", "c", "t" }) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      local rhs = map.rhs or ""
      local cmd = rhs:match("^<[Cc][Mm][Dd]>(%u[%w_]*)") or rhs:match("^:(%u[%w_]*)")
      -- exists()는 없으면 0, 여러 명령과 겹쳐 모호하면 3을 돌려준다.
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

-- `-c`는 VimEnter 전에 실행되므로, 시작 autocmd가 끝난 VimEnter 이후에 시작한다.
-- startup 중 setup()이 예약한 알림은 run()보다 먼저 실행되므로, 훅은 VimEnter에서 바로 건다.
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
