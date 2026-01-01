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
    width = 200,
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

local tmux_term = Terminal:new({
  cmd = "tmux new -A -s toggle",
  close_on_exit = false,
  direction = "float",
})

local function toggle_tmux_session()
  tmux_term:toggle()
end

vim.keymap.set({ "n", "t" }, "<D-g>", toggle_tmux_session, { desc = "Toggle tmux session in toggleterm" })
vim.keymap.set({ "n", "t" }, "<M-g>", toggle_tmux_session, { desc = "Toggle tmux session in toggleterm" })
