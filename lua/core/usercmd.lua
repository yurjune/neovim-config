vim.api.nvim_create_user_command("W", "w", { desc = "Save current file" })
vim.api.nvim_create_user_command("Wq", "wq", { desc = "Save and quit current file" })
vim.api.nvim_create_user_command("Q", "q", { desc = "Quit current file" })
vim.api.nvim_create_user_command("Qa", "qa", { desc = "Quit all files" })

vim.api.nvim_create_user_command("NodeCurrentFile", function()
  local file_path = vim.fn.expand("%")
  vim.cmd("terminal node " .. vim.fn.fnameescape(file_path))
end, { desc = "Run current file on node" })

-- Show LSP info
vim.api.nvim_create_user_command("LspInfo", function()
  local clients = vim.lsp.get_active_clients()
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {}

  -- table headers
  table.insert(lines, "Language client log: " .. vim.lsp.get_log_path())
  table.insert(lines, "Detected filetype: " .. vim.bo.filetype)
  table.insert(lines, "")

  if #clients == 0 then
    table.insert(lines, "No active clients")
  else
    local currente_buf_clients = vim.lsp.get_active_clients({ bufnr = 0 })
    if #currente_buf_clients > 0 then
      table.insert(lines, vim.inspect(#currente_buf_clients) .. " client(s) attached to this buffer:")
      table.insert(lines, "")
      for _, client in ipairs(currente_buf_clients) do
        table.insert(lines, "Client: " .. client.name .. " (id: " .. client.id .. ")")
        table.insert(lines, "  filetypes: " .. vim.inspect(client.config.filetypes or {}))
        table.insert(lines, "  root directory: " .. (client.config.root_dir or "Not set"))
        table.insert(lines, "  cmd: " .. vim.inspect(client.config.cmd or {}))
        table.insert(lines, "")
      end
    end

    local other_clients = {}
    for _, client in ipairs(clients) do
      local is_current = false
      for _, buf_client in ipairs(currente_buf_clients) do
        if client.id == buf_client.id then
          is_current = true
          break
        end
      end
      if not is_current then
        table.insert(other_clients, client)
      end
    end

    if #other_clients > 0 then
      table.insert(lines, "Other active clients not attached to this buffer:")
      table.insert(lines, "")
      for _, client in ipairs(other_clients) do
        table.insert(lines, "Client: " .. client.name .. " (id: " .. client.id .. ")")
        table.insert(lines, "")
      end
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")

  -- show buffer in a split window
  vim.cmd("split")
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_name(buf, "LSP Info")

  -- how to close
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
end, {})
