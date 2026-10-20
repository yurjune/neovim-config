vim.api.nvim_create_user_command("W", "w", { desc = "Save current file" })
vim.api.nvim_create_user_command("Wq", "wq", { desc = "Save and quit current file" })
vim.api.nvim_create_user_command("WQ", "wq", { desc = "Save and quit current file" })

vim.api.nvim_create_user_command("Q", "q", { desc = "Quit current file" })
vim.api.nvim_create_user_command("Qa", "qa", { desc = "Quit all files" })
vim.api.nvim_create_user_command("QA", "qa", { desc = "Quit all files" })
vim.api.nvim_create_user_command("QQ", "qa!", { desc = "Quit all files force" })

vim.api.nvim_create_user_command("R", function()
  pcall(function()
    -- auto-session does not support saving session before restart
    require("auto-session").auto_save_session()
  end)

  vim.cmd("restart")
end, { desc = "Restart Neovim" })

vim.api.nvim_create_user_command("NodeCurrentFile", function()
  local file_path = vim.fn.expand("%")
  vim.cmd("terminal node " .. vim.fn.fnameescape(file_path))
end, { desc = "Run current file on node" })

vim.api.nvim_create_user_command("MarkdownHeadingUp", function()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local fence = nil

  for index, line in ipairs(lines) do
    local marker = line:match("^%s*(```+)") or line:match("^%s*(~~~+)")
    if fence then
      -- A fence closes only with the same character and at least as many of them.
      if marker and marker:sub(1, 1) == fence:sub(1, 1) and #marker >= #fence then
        fence = nil
      end
    elseif marker then
      fence = marker
    else
      -- Levels deeper than 6 are not headings, so leave them alone.
      local hashes = line:match("^(#+)%s")
      if hashes and #hashes < 6 then
        vim.api.nvim_buf_set_lines(buf, index - 1, index, false, { "#" .. line })
      end
    end
  end
end, { desc = "Increase every heading level by one" })
