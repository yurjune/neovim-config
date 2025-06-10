-- tabs & indentation
vim.opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
vim.opt.shiftwidth = 2 -- 2 spaces for indent width
vim.opt.expandtab = true -- expand tab to spaces
vim.opt.autoindent = true -- copy indent from current line when starting new one

-- lines
vim.opt.relativenumber = true
vim.opt.number = true -- mark current line number
vim.opt.wrap = false -- if false, disable line wrapping when text overflows

if vim.g.leetcode then
  -- make wordwrap in question window, since leetcode.nvim set nowrap internally
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = "*",
    callback = function()
      if vim.bo.filetype == "leetcode.nvim" then -- apply on question window only
        vim.opt_local.wrap = true
      end
    end,
  })
end

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
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- remove auto fold open condition: horizontal move
    -- vim.opt.foldopen:remove("hor")
  end,
})

-- Decide what inormation to save when saving a session
-- localoptions: local options set for each window or buffer
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- cursor
vim.opt.cursorline = true -- highlight the current cursor line
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait480-blinkoff480-blinkon480" -- blink cursor

vim.opt.termguicolors = true -- 터미널에서 24bit true color 를 사용할지를 결정
vim.opt.background = "dark" -- 현재 사용중인 컬러 스키마가 dark or light 에 최적화되도록 조정
vim.opt.signcolumn = "yes" -- 편집기 왼쪽에 표시되는 sign 의 제어방식을 결정

vim.opt.backspace = "indent,eol,start" -- allow backspace condition
vim.opt.clipboard:append("unnamedplus") -- use system clipboard as default register

vim.opt.swapfile = false -- 편집 중인 파일의 swap file 을 생성할지를 결정
vim.opt.autoread = true -- automatically read file when it is changed outside of vim

vim.opt.scrolloff = 4 -- number of lines to keep above and below the cursor

vim.opt.list = true
---@diagnostic disable-next-line: missing-fields
vim.opt.listchars = {
  tab = ">·",
  lead = "·",
  trail = "·",
  extends = ">",
  precedes = "<",
}
