vim.g.mapleader = " " -- bind spacebar to leader key

-- Clipboard keymaps
vim.keymap.set("n", "<D-c>", '"+y')
vim.keymap.set("v", "<D-c>", '"+y')
vim.keymap.set("n", "<D-v>", '"+p')
vim.keymap.set("i", "<D-v>", "<c-r>+")
vim.keymap.set("c", "<D-v>", "<c-r>+")
vim.keymap.set("t", "<D-v>", [[<C-\><C-n>"+pi]])

-- Keymaps using command
vim.keymap.set("n", "<D-s>", "<cmd>w<CR>", { desc = "Save current file" })
vim.keymap.set("n", "<M-s>", "<cmd>w<CR>", { desc = "Save current file" })
vim.keymap.set("n", "<D-a>", "ggVG", { desc = "Select all lines" })
vim.keymap.set("n", "<M-a>", "ggVG", { desc = "Select all lines" })

vim.keymap.set("n", "<C-q>", "<C-6>", { desc = "Switch to last accessed buffer" })
vim.keymap.set("n", "<C-6>", "<Nop>")

vim.keymap.set("n", "<leader>rq", ":cexpr [] | cclose<CR>", { desc = "Reset and close quick-fix" })
-- vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, desc = "change to normal mode" })

vim.keymap.set("n", "<leader>[[", "<cmd>qa!<CR>", { desc = "Exit neovim by force" })

vim.keymap.set("n", "gh", function()
  local windows = vim.api.nvim_tabpage_list_wins(0)
  for _, win in ipairs(windows) do
    local config = vim.api.nvim_win_get_config(win)
    -- Check if the window is a floating window, since normal windows won't have a relative property
    if config.relative ~= "" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end, { desc = "Focus on floating window" })

vim.keymap.set("n", "'", "`", { noremap = true, desc = "Go to mark" })

vim.keymap.set("n", "<leader>md", function()
  local lnum = vim.fn.line(".")
  local curbuf = vim.api.nvim_get_current_buf()
  local removed = {}

  local function try_del(mark, is_global)
    local pos = vim.fn.getpos("'" .. mark)
    local bufnr, line = pos[1], pos[2]

    if is_global then
      if bufnr == curbuf and line == lnum then
        vim.cmd("delmarks " .. mark)
        table.insert(removed, mark)
      end
    else
      if (bufnr == 0 or bufnr == curbuf) and line == lnum then
        vim.cmd("delmarks " .. mark)
        table.insert(removed, mark)
      end
    end
  end

  -- local marks
  for c = string.byte("a"), string.byte("z") do
    try_del(string.char(c), false)
  end

  -- global marks
  for c = string.byte("A"), string.byte("Z") do
    try_del(string.char(c), true)
  end

  if #removed > 0 then
    vim.notify("Deleted marks: " .. table.concat(removed, ", "), vim.log.levels.INFO, { title = "Marks" })
  end
end, { desc = "Delete all marks on current line" })

vim.keymap.set("n", "<leader>mc", function()
  vim.cmd("delmarks!")
  vim.notify("a-z marks in current buffer cleared", vim.log.levels.INFO)
end, { desc = "Clear a-z marks in current buffer" })

vim.keymap.set("n", "<leader>mC", function()
  vim.cmd("delmarks A-Z")
  vim.notify("A-Z marks cleared", vim.log.levels.INFO)
end, { desc = "Clear A-Z marks" })

-- Copy current file paths
vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.expand("%")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copy Relative Path" })
end, { desc = "Copy relative path of current file" })

vim.keymap.set("n", "<leader>cP", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copy Absolute Path" })
end, { desc = "Copy absolute path of current file" })
