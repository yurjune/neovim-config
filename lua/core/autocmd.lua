vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- option for remove continue commenting when line changes
    -- r: continue commenting when line changed by enter
    -- o: continue commenting when line changed by o or O command
    vim.opt_local.formatoptions:append({ "r", "o" })
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
