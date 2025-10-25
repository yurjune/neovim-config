vim.lsp.enable({
  "lua_ls",
  "ts_ls",
  -- "copilot",
  "rust_analyzer",
  "emmet_ls",
  "svelte",
  "marksman",
  "tailwindcss",
  "sqls",
  "css_lsp",
  "css_variables",
  "css_modules",
  "some_sass",
  "html_ls",
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

-- Enable LLM-based inline completion
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local support_inline = client and client.server_capabilities.inlineCompletionProvider
    local disabled = true
    if not support_inline or vim.g.leetcode or disabled then
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

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local navic_ok, navic = pcall(require, "nvim-navic")

    -- attach nvim-navic plugin to LSP clients
    if navic_ok and client and client.server_capabilities.documentSymbolProvider then
      navic.attach(client, ev.buf)
    end
  end,
})

-- Show LSP info
vim.api.nvim_create_user_command("LspInfo", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {}

  if #clients == 0 then
    lines[1] = "No LSP attached"
  else
    lines[1] = "Attached LSP clients:"
    for _, client in ipairs(clients) do
      lines[#lines + 1] = "  • " .. client.name
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe" -- clear buf when window closed

  -- show buffer in a split window
  vim.cmd("split")
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_set_name(buf, "LSP Info")
end, {})
