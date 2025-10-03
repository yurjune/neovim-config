vim.lsp.enable({
  "lua_ls",
  "ts_ls",
  "rust_analyzer",
  "emmet_ls",
  "svelte",
  "marksman",
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

-- Activate LSP completion
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.supports_method("textDocument/completion") then
      -- Enable completion
      vim.lsp.completion.enable(true, client.id, ev.buf, {
        -- if True, completion select will automatically trigger after inserting a character
        autotrigger = false,
      })
    end
  end,
})

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
