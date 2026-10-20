vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  desc = "Markdown editing keymaps and commands",
  callback = function(ev)
    require("etc.markdown.heading").setup(ev.buf)
    require("etc.markdown.emphasis").setup(ev.buf)
  end,
})
