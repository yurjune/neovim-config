-- A plugin to persist and toggle multiple terminals during an editing session
vim.pack.add({
  "https://github.com/akinsho/toggleterm.nvim",
})
vim.cmd.packadd("toggleterm.nvim")

require("toggleterm").setup({
  size = 22,
  -- 숫자 + 단축키로 여러 터미널 세션을 관리할 수 있다.
  open_mapping = nil,
  start_in_insert = true,
  insert_mappings = true, -- whether or not the open mapping applies in insert mode
  terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
  auto_scroll = true, -- automatically scroll to the bottom on terminal output
  persist_size = true,
  persist_mode = false, -- if set to true (default) the previous terminal mode will be remembered

  direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float'
  -- This field is only relevant if direction is set to 'float'
  float_opts = {
    border = "curved", -- 'single' | 'double' | 'shadow' | 'curved'
    width = 180,
    height = 45,
  },
})

local Terminal = require("toggleterm.terminal").Terminal
vim.api.nvim_create_user_command("TestCurrentFile", function()
  Terminal:new({
    cmd = "npx jest " .. vim.fn.shellescape(vim.fn.expand("%")),
    close_on_exit = false,
    direction = "float",
  }):toggle()
end, { desc = "Run test current file in toggleterm" })

vim.api.nvim_create_user_command("TestCurrentFileCoverage", function()
  Terminal:new({
    cmd = "npx jest " .. vim.fn.shellescape(vim.fn.expand("%")) .. " --coverage",
    close_on_exit = false,
    direction = "float",
  }):toggle()
end, { desc = "Get test coverage of current file in toggleterm" })

local function get_project_root()
  -- Prefer VCS/project markers, fall back to cwd.
  local root = vim.fs.root(0, { ".git", "package.json", "pyproject.toml", "go.mod", "Cargo.toml" })
  return root or vim.fn.getcwd()
end

local function tmux_session_name(root)
  local base = vim.fs.basename(root)
  local hash = vim.fn.sha256(root):sub(1, 8)
  return ("toggle_%s_%s"):format(base, hash)
end

local tmux_terms_by_root = {}

local function toggle_tmux_session()
  local root = get_project_root()
  local term = tmux_terms_by_root[root]
  if not term then
    term = Terminal:new({
      cmd = "tmux new -A -s " .. tmux_session_name(root),
      dir = root,
      close_on_exit = false,
      direction = "float",
    })
    tmux_terms_by_root[root] = term
  end
  term:toggle()
end

vim.keymap.set({ "n", "t" }, "<D-g>", toggle_tmux_session, { desc = "Toggle tmux session in toggleterm" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.keymap.set("n", "<leader>cb", function()
      Terminal:new({
        cmd = "cargo run",
        close_on_exit = false,
        direction = "float",
      }):toggle()
    end, { desc = "Cargo run", buffer = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "c",
  callback = function()
    vim.keymap.set("n", "<leader>cb", function()
      local dir = vim.fn.expand("%:p:h")
      Terminal:new({
        cmd = string.format("cd %s && gcc *.c && ./a.out && rm a.out", vim.fn.shellescape(dir)),
        close_on_exit = false,
        direction = "float",
      }):toggle()
    end, { desc = "Compile current dir and run program", buffer = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "cpp",
  callback = function()
    vim.keymap.set("n", "<leader>cb", function()
      local dir = vim.fn.expand("%:p:h")
      Terminal:new({
        cmd = string.format("cd %s && g++ *.cpp && ./a.out && rm a.out", vim.fn.shellescape(dir)),
        close_on_exit = false,
        direction = "float",
      }):toggle()
    end, { desc = "Compile current dir and run program", buffer = true })
  end,
})
