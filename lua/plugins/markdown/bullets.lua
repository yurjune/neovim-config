vim.pack.add({
  "https://github.com/bullets-vim/bullets.vim",
})
vim.cmd.packadd("bullets.vim")

local ft = { "markdown", "text", "gitcommit", "scratch" } -- Configure globals before loading the plugin so it reads them on startup.
vim.g.bullets_enabled_file_types = {
  "markdown",
  "text",
  "gitcommit",
  "scratch",
}

vim.g.bullets_custom_mappings = {
  { "imap", "<cr>", "<Plug>(bullets-newline)" },
  { "nmap", "o", "<Plug>(bullets-newline)" },
  { "inoremap", "<C-cr>", "<cr>" },
  { "vmap", "gN", "<Plug>(bullets-renumber)" },
  { "nmap", "gN", "<Plug>(bullets-renumber)" },
  { "nmap", "<leader>x", "<Plug>(bullets-toggle-checkbox)" },
  { "imap", "<C-t>", "<Plug>(bullets-demote)" },
  { "imap", "<C-d>", "<Plug>(bullets-promote)" },
  { "nmap", ">>", "<Plug>(bullets-demote)" },
  { "nmap", "<<", "<Plug>(bullets-promote)" },
  { "vmap", ">", "<Plug>(bullets-demote)" },
  { "vmap", "<", "<Plug>(bullets-promote)" },
}

-- num -> abc -> rom -> num loops
-- use only - mark for bullet
vim.g.bullets_outline_levels = { "num", "abc", "rom", "num" }
vim.g.bullets_enable_in_empty_buffers = 1
vim.g.bullets_auto_indent_after_colon = 1
vim.g.bullets_renumber_on_change = 0
vim.g.bullets_delete_last_bullet_if_empty = 1 -- empty bullet 에서 줄바꿈 시 bullet 제거 및 들여쓰기 초기화
vim.g.bullets_max_alpha_characters = 2 -- alphabet bullet 을 n자 까지 허용, ex) 2이면 "z" 이후 "aa"
vim.g.bullets_checkbox_markers = " .ox"
vim.g.bullets_nested_checkboxes = 1 -- 1이면 부모-자식 체크박스 연동, 0이면 독립적으로 동작
vim.g.bullets_checkbox_partials_toggle = 1 -- 부분 완료 체크박스 토글 시 1이면 전체 완료, 0이면 전체 미완료로 토글

vim.api.nvim_create_autocmd("FileType", {
  pattern = ft,
  callback = function(args)
    vim.keymap.set(
      "n",
      "<leader>bt",
      "<Plug>(bullets-toggle-checkbox)",
      { buffer = args.buf, desc = "toggle checkbox" }
    )
    vim.keymap.set("n", "<leader>br", "<Plug>(bullets-renumber)", { buffer = args.buf, desc = "renumber bullets" })
    vim.keymap.set("v", "<leader>br", "<Plug>(bullets-renumber)", { buffer = args.buf, desc = "renumber bullets" })
    vim.keymap.set("n", "<leader>bc", function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local new_line = line:sub(1, col) .. "- [ ] " .. line:sub(col + 1)
      vim.api.nvim_set_current_line(new_line)
      vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], col + 6 })
    end, { buffer = args.buf, desc = "create checkbox" })
  end,
})
