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
vim.opt.splitright = true -- split vertical window to the right
vim.opt.splitbelow = true -- split horizontal window to the bottom

-- cases
vim.opt.ignorecase = true -- case-insensitive
-- true 이면 소문자만 포함 시 case-insensitive, 대문자가 하나라도 포함되면 case-sensitive
-- works on only ignorecase = true
vim.opt.smartcase = false

-- fold
vim.opt.foldenable = true
vim.opt.foldmethod = "expr" -- indent, expr, syntax, manual, diff, marker
vim.opt.foldlevel = 99 -- make all unfolded in default
-- 각 라인의 폴딩 레벨을 결정하는 표현식을 지정
-- works on only foldmethod = expr
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- vim.opt.foldtext = ""

-- cursor
vim.opt.cursorline = true -- highlight the current cursor line
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait530-blinkoff530-blinkon530" -- blink cursor

vim.opt.termguicolors = true -- 터미널에서 24bit true color 를 사용할지를 결정
vim.opt.background = "dark" -- 현재 사용중인 컬러 스키마가 dark or light 에 최적화되도록 조정
vim.opt.signcolumn = "yes" -- 편집기 왼쪽에 표시되는 sign 의 제어방식을 결정

vim.opt.backspace = "indent,eol,start" -- allow backspace condition
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
