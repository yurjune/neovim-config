-- A plugin for indentation guides
vim.pack.add({ "https://github.com/lukas-reineke/indent-blankline.nvim" })
vim.cmd.packadd("indent-blankline.nvim")

local ibl = require("ibl")

ibl.setup({
  enabled = true,
  debounce = 100,
  indent = {
    char = "¦",
    smart_indent_cap = true, -- 과한 들여쓰기 수준에서 시각적 혼란을 감소
    repeat_linebreak = true, -- 줄 바꿈 시 들여쓰기 표시를 반복할지 여부를 결정
  },
  scope = {
    show_start = false, -- 현재 스코프에 대한 밑줄 표 여부
    show_end = false,
    show_exact_scope = false,
  },
})
