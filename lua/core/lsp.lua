vim.lsp.enable({
  "lua_ls",
  "ts_ls",
  "copilot",
  "rust_analyzer",
  "emmet_ls",
  "svelte",
  "marksman",
  "tailwindcss",
  "sqls",
})

local lsp_group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

-- LSP config for keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = ev.buf,
        silent = true,
        desc = desc,
      })
    end

    -- Remove built in keymaps for lsp buf starts with "gr"
    local gr_mappings = { "grn", "gra", "grr", "gri", "grt" }
    for _, mapping in ipairs(gr_mappings) do
      pcall(vim.keymap.del, "n", mapping)
      pcall(vim.keymap.del, "x", mapping)
    end

    local tele_builtin = require("telescope.builtin")

    map("n", "gl", "gd", "Show local definitions")
    map("n", "gd", tele_builtin.lsp_definitions, "Show LSP definitions")
    map("n", "gr", tele_builtin.lsp_references, "Show LSP references")
    map("n", "gi", tele_builtin.lsp_implementations, "Show LSP implementations")
    map("n", "K", vim.lsp.buf.hover, "Show documentation for what is under cursor")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Smart rename")
    map({ "n", "v" }, "<leader>q", vim.lsp.buf.code_action, "Code actions")

    map("n", "<leader>db", function()
      tele_builtin.diagnostics({ bufnr = 0 })
    end, "Show current buffer diagnostics")

    map("n", "<leader>dw", function()
      tele_builtin.diagnostics({
        bufnr = nil, -- 0은 현재 버퍼
        severity = nil, -- nil 이면 모든 심각도 수준
        root_dir = nil, -- nil이면 모든 파일 포함 (전체 워크스페이스)
      })
    end, "Show workspace diagnostics")

    map("n", "<leader>dl", vim.diagnostic.open_float, "Show line diagnostics")
    map("n", "<leader>rs", "<cmd>LspRestart<CR>", "Restart LSP")
  end,
})

-- LSP config for ts-ls
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if client and client.name == "ts_ls" then
      local function organize_imports()
        vim.lsp.buf.code_action({
          context = {
            only = { "source.organizeImports.ts" },
          },
          apply = true,
        })
        vim.notify("Organize imports triggered", vim.log.levels.INFO, { title = "LSP" })
      end

      local function remove_unused()
        vim.lsp.buf.code_action({
          context = {
            only = { "source.removeUnused" },
          },
          apply = true,
        })
        vim.notify("Remove unused triggered", vim.log.levels.INFO, { title = "LSP" })
      end

      vim.api.nvim_create_user_command("OrganizeImports", organize_imports, {})
      vim.api.nvim_create_user_command("RemoveUnused", remove_unused, {})

      vim.keymap.set("n", "<leader>oi", organize_imports, { desc = "Organize Imports", buffer = ev.buf })
      vim.keymap.set("n", "<leader>ru", remove_unused, { desc = "Remove unused", buffer = ev.buf })
    end
  end,
})

-- Enable LLM-based inline completion
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local support_inline = client and client.server_capabilities.inlineCompletionProvider
    if not support_inline or vim.g.leetcode then
      return
    end

    vim.g.inline_completion_enabled = true
    vim.lsp.inline_completion.enable()

    local excluded_ft = { "markdown" }
    local buf_ft = vim.bo[ev.buf].filetype
    if vim.tbl_contains(excluded_ft, buf_ft) then
      vim.g.inline_completion_enabled = false
      vim.lsp.inline_completion.enable(false)
    end

    vim.keymap.set("n", "<leader>ct", function()
      local next = not vim.g.inline_completion_enabled
      vim.g.inline_completion_enabled = next
      vim.lsp.inline_completion.enable(next)
      local text = next and "ENABLED" or "DISABLED"
      vim.notify("Inline completion " .. text, vim.log.levels.INFO, { title = "LSP" })
    end, { desc = "Toggle inline completion", buffer = ev.buf })

    -- handle suggestion accept event in sidekick.nvim
    -- vim.keymap.set("i", "<Tab>", function()
    --   if not vim.lsp.inline_completion.get() then
    --     return "<Tab>"
    --   end
    -- end, { expr = true, desc = "Apply the currently displayed completion suggestion" })

    -- next completion
    for _, key in ipairs({ "<D-j>", "<M-j>" }) do
      vim.keymap.set("i", key, function()
        vim.lsp.inline_completion.select({})
      end, { desc = "Show next inline completion suggestion" })
    end

    -- prev completion
    for _, key in ipairs({ "<D-k>", "<M-k>" }) do
      vim.keymap.set("i", key, function()
        vim.lsp.inline_completion.select({ count = -1 })
      end, { desc = "Show previous inline completion suggestion" })
    end
  end,
})

-- Enable inlay hints
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local support = client and client.server_capabilities.inlayHintProvider
    if support then
      vim.lsp.inlay_hint.enable(false, { bufnr = ev.buf })

      vim.keymap.set("n", "<leader>ih", function()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = ev.buf })

        local text = enabled and "DISABLED" or "ENABLED"
        vim.notify("Inlay hints " .. text, vim.log.levels.INFO, { title = "LSP" })
      end, { desc = "Toggle inlay hints", buffer = ev.buf })
    end
  end,
})

-- Disable built-in completion when using nvim-cmp
-- Activate LSP completion
-- vim.api.nvim_create_autocmd("LspAttach", {
--   group = lsp_group,
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     if client and client.supports_method("textDocument/completion") then
--       -- Enable completion
--       vim.lsp.completion.enable(true, client.id, ev.buf, {
--         -- if True, completion select will automatically trigger after inserting a character
--         autotrigger = false,
--       })
--     end
--   end,
-- })

-- For Svelte lsp
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if client and client.name == "svelte" then
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = lsp_group,
        -- When JS/TS file changes which is imported by Svelte file,
        pattern = { "*.js", "*.ts" },
        callback = function(ctx)
          -- Notify Svelte LSP that the file has changed, so that LSP server can update type info and diagnostics
          client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
        end,
      })
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local navic_ok, navic = pcall(require, "nvim-navic")

    -- attach nvim-navic plugin to LSP clients
    if navic_ok and client.server_capabilities.documentSymbolProvider then
      navic.attach(client, ev.buf)
    end
  end,
})

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
