-- Automatically load project-specific .nvim.lua settings.
vim.opt.exrc = true

-- Identify concurrent Neovim sessions in the terminal tab title.
vim.opt.title = true
vim.opt.titlestring = "nvim — %{fnamemodify(getcwd(), ':t')}"

-- tabs & indentation
vim.opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
vim.opt.shiftwidth = 2 -- 2 spaces for indent width
vim.opt.expandtab = true -- expand tab to spaces
vim.opt.autoindent = true -- copy indent from current line when starting new one

-- lines
vim.opt.relativenumber = true
vim.opt.number = true -- mark current line number
vim.opt.wrap = false -- if false, disable line wrapping when text overflows

-- split windows
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.equalalways = true

-- diff
vim.opt.diffopt:append("algorithm:histogram") -- "myers", "minimal", "patience", "histogram"

-- cases
vim.opt.ignorecase = true -- case-insensitive
-- true 이면 소문자만 포함 시 case-insensitive, 대문자가 하나라도 포함되면 case-sensitive
-- works on only ignorecase = true
vim.opt.smartcase = false

-- fold
vim.opt.foldenable = true
-- initial fold level when opening a file
-- level 0 means everything folded, 99 means everything unfolded
vim.opt.foldlevelstart = 99
-- fold level of the current window
vim.opt.foldlevel = 99

-- Decide what inormation to save when saving a session
-- localoptions: local options set for each window or buffer
vim.opt.sessionoptions = {
  "buffers", -- Save all buffers, including hidden ones
  "curdir", -- Save the current working directory
  "folds", -- Save fold states
  "winsize", -- Save window sizes
  "winpos", -- Save the GUI window position
  "localoptions", -- Save buffer-local and window-local options
  "globals", -- Save eligible global variables
}

-- cursor
vim.opt.cursorline = true -- highlight the current cursor line
vim.opt.guicursor = {
  "n-v-c-sm:block",
  "i-ci-ve:ver25",
  "r-cr:hor20",
  "o:hor50",
  "a:blinkwait480-blinkoff480-blinkon480-EditorCursor",
}

-- Persist undo history across Neovim sessions
vim.opt.undofile = true

vim.opt.termguicolors = true -- use 24bit true color in terminal
vim.opt.signcolumn = "yes"

local is_ssh = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil
local clipboard_group = vim.api.nvim_create_augroup("SshClipboard", { clear = true })

if is_ssh then
  -- Keep p local; paste external clipboard contents with the terminal's paste shortcut.
  vim.opt.clipboard:remove({ "unnamed", "unnamedplus" })
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = clipboard_group,
    desc = "Copy SSH yanks to the local clipboard via OSC 52",
    callback = function()
      if vim.v.event.operator == "y" and vim.v.event.regname ~= "_" then
        require("vim.ui.clipboard.osc52").copy("+")(vim.v.event.regcontents)
      end
    end,
  })
else
  vim.opt.clipboard:append("unnamedplus") -- use system clipboard as default register
end

vim.opt.swapfile = false -- 편집 중인 파일의 swap file 을 생성할지를 결정

vim.opt.scrolloff = 2 -- number of lines to keep above and below the cursor

vim.opt.list = true
vim.opt.listchars = {
  tab = ">·",
  leadmultispace = "· ",
  trail = "·",
  extends = ">",
  precedes = "<",
}
