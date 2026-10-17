vim.filetype.add({
  pattern = {
    [".*/Jenkinsfile%..*"] = "groovy",
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- Filetype plugins can change formatoptions; apply these settings to each buffer.
    -- r: continue comments when starting a new line with Enter
    -- o: continue comments when starting a new line with o or O
    vim.opt_local.formatoptions:append("r")
    vim.opt_local.formatoptions:remove("o")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function(args)
    vim.keymap.set("n", "<Tab>", "<CR>", {
      buffer = args.buf,
      remap = true,
      silent = true,
      desc = "Open quickfix item",
    })
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
