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
vim.opt.equalalways = true -- always make split windows equal width & height

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
-- foldmethod means how to determine the folds and its level, ex) indent, expr, syntax, manual, diff, marker
vim.opt.foldmethod = "expr"
-- 각 라인의 폴딩 레벨을 결정하는 표현식을 지정, works on only foldmethod = expr
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- 항상 N칸 폭의 foldcolumn 을 표시, auto:N 이면 최대 N칸 폭의 foldcolumn 을 표시
vim.opt.foldcolumn = "0"

-- Decide what inormation to save when saving a session
-- localoptions: local options set for each window or buffer
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- cursor
vim.opt.cursorline = true -- highlight the current cursor line
vim.opt.guicursor = {
  "n-v-c-sm:block",
  "i-ci-ve:ver25",
  "r-cr:hor20",
  "o:hor50",
  "a:blinkwait480-blinkoff480-blinkon480",
}

vim.opt.termguicolors = true -- use 24bit true color in terminal
vim.opt.signcolumn = "yes"

vim.opt.clipboard:append("unnamedplus") -- use system clipboard as default register

vim.opt.swapfile = false -- 편집 중인 파일의 swap file 을 생성할지를 결정

vim.opt.scrolloff = 4 -- number of lines to keep above and below the cursor

vim.opt.list = true
vim.opt.listchars = {
  tab = ">·",
  lead = "·",
  trail = "·",
  extends = ">",
  precedes = "<",
}

-- claude code 로 파일을 수정했을 때 생기는 문제 방지(검증 중)
vim.opt.fixeol = false -- 파일 끝 개행 문자 자동 수정 활성화 여부
vim.opt.eol = false -- 파일 끝 개행 문자 활성화 여부
