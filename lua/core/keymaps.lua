vim.g.mapleader = " " -- bind spacebar to leader key

vim.keymap.set("n", "<leader>rq", ":cexpr [] | cclose<CR>", { desc = "Reset and close quick-fix" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, desc = "change to normal mode" })
