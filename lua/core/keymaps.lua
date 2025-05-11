vim.g.mapleader = " " -- bind spacebar to leader key

vim.keymap.set("n", "<leader>rq", ":cexpr [] | cclose<CR>", { desc = "Reset and close quick-fix" })
