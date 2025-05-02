-- A plugin for configuring Language Server Protocol(LSP)
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local keymap = vim.keymap

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),

      callback = function(ev)
        local tele_builtin = require("telescope.builtin")
        local opts = {
          buffer = ev.buf, -- key mappings works on specific buffer
          silent = true,
        }

        keymap.set("n", "gl", "gd", { desc = "Show local definitions" })

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", tele_builtin.lsp_definitions, opts)

        opts.desc = "Show LSP references"
        keymap.set("n", "gr", tele_builtin.lsp_references, opts)

        -- opts.desc = "Show LSP type definitions"
        -- keymap.set("n", "", tele_builtin.lsp_type_definitions, opts)

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", tele_builtin.lsp_implementations, opts)

        opts.desc = "Show current buffer diagnostics"
        keymap.set("n", "<leader>db", function()
          tele_builtin.diagnostics({ bufnr = 0 })
        end, opts)

        opts.desc = "Show workspace diagnostics"
        keymap.set("n", "<leader>dw", function()
          tele_builtin.diagnostics({
            bufnr = nil, -- 0은 현재 버퍼
            severity = nil, -- nil 이면 모든 심각도 수준
            root_dir = nil, -- nil이면 모든 파일 포함 (전체 워크스페이스)
          })
        end, opts)

        opts.desc = "Show line diagnostics"
        vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, opts)

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", "<cmd>LspRestart<CR>", opts)

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Code actions"
        keymap.set({ "n", "v" }, "<leader>q", vim.lsp.buf.code_action, opts)
      end,
    })

    -- Change the Diagnostic symbols in the sign column (gutter)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    local function remove_unused()
      local params = {
        context = {
          diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
          only = { "source.removeUnused" },
        },
        apply = true,
      }
      vim.lsp.buf.code_action(params)
      vim.notify("Remove unused triggered", vim.log.levels.INFO, { title = "LSP" })
    end

    -- how can i execute this asynchonously?
    local function organize_imports()
      vim.lsp.buf.execute_command({
        command = "_typescript.organizeImports",
        title = "",
        arguments = { vim.api.nvim_buf_get_name(0) },
      })
      vim.notify("Organize Imports triggered", vim.log.levels.INFO, { title = "LSP" })
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
      callback = function()
        -- keymap.set("n", "<leader>oi", organize_imports, { desc = "Organize Imports", buffer = true })
        keymap.set("n", "<leader>ru", remove_unused, { desc = "Remove unused", buffer = true })
      end,
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    mason_lspconfig.setup_handlers({
      -- default handler for installed servers
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      ["ts_ls"] = function()
        lspconfig["ts_ls"].setup({
          capabilities = capabilities,
          init_options = {
            preferences = {
              -- prevent using alias when execute smart rename
              -- useAliasesForRenames = false option doesn't work... but this works.
              providePrefixAndSuffixTextForRename = false,
            },
          },
          commands = {
            OrganizeImports = {
              organize_imports,
              description = "Organize Imports",
            },
            RemoveUnused = {
              remove_unused,
              description = "Remove Unused",
            },
          },
        })
      end,
      ["emmet_ls"] = function()
        lspconfig["emmet_ls"].setup({
          capabilities = capabilities,
          filetypes = {
            "html",
            "css",
            "scss",
            "typescriptreact",
            "javascriptreact",
            "svelte",
          },
        })
      end,
      ["svelte"] = function()
        lspconfig["svelte"].setup({
          capabilities = capabilities,
          on_attach = function(client)
            vim.api.nvim_create_autocmd("BufWritePost", {
              pattern = { "*.js", "*.ts" },
              callback = function(ctx)
                -- Svelte 컴포넌트가 참조하는 외부 TS/JS 파일이 변경되면 Svelte 서버에 알려 컴포넌트를 업데이트
                client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
              end,
            })
          end,
        })
      end,
    })
  end,
}
