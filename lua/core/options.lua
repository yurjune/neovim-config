-- 파일 탐색기 형식에 트리(3)를 사용
vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

-- line numbers
opt.relativenumber = true
opt.number = true -- 현재 줄의 라인 넘버를 표시

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
-- 텍스트가 화면을 넘어가도 한줄로 표시
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line
-- cursor blink
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait530-blinkoff530-blinkon530"

-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
-- 시스템 클립보드를 기본 레지스터로 사용
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false
