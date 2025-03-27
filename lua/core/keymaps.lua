vim.g.mapleader = " " -- <leader>은 space를 의미

-- vim Ex 명령어 설정
-- 사용자 명령어는 대문자로 시작해야함

-- ex) :Tc == :tabclose
vim.api.nvim_create_user_command('Tc', 'tabclose', {})
