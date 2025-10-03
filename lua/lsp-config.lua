vim.lsp.enable({
  "lua_ls",
  "ts_ls",
  "rust_analyzer",
  "emmet_ls",
  "svelte",
  "marksman",
})

local lsp_group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local bufnr = ev.buf

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = bufnr,
        silent = true,
        desc = desc,
      })
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

      map("n", "<leader>oi", organize_imports, "Organize Imports")
      map("n", "<leader>ru", remove_unused, "Remove unused")
    end

    -- attach nvim-navic plugin to LSP clients
    local navic_ok, navic = pcall(require, "nvim-navic")
    if navic_ok and client.server_capabilities.documentSymbolProvider then
      navic.attach(client, bufnr)
    end
  end,
})

local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
vim.diagnostic.config({
  underline = true,
  update_in_insert = true,
  severity_sort = true,
  virtual_text = {
    prefix = "■",
    spacing = 4,
    source = "if_many",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = signs.Error,
      [vim.diagnostic.severity.WARN] = signs.Warn,
      [vim.diagnostic.severity.INFO] = signs.Info,
      [vim.diagnostic.severity.HINT] = signs.Hint,
    },
  },
  float = {
    border = "rounded",
    winhighlight = "Normal:DiagnosticFloat,FloatBorder:DiagnosticBorder",
  },
})

-- Activate LSP completion
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.supports_method("textDocument/completion") then
      -- Enable completion
      vim.lsp.completion.enable(true, client.id, ev.buf, {
        -- Automatically trigger completion after typing
        autotrigger = true,
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
