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
    local keymap = vim.keymap -- for conciseness

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        local tele_builtin = require("telescope.builtin")

        -- set keybinds
        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", tele_builtin.lsp_definitions, opts)

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Show LSP references"
        keymap.set("n", "gr", tele_builtin.lsp_references, opts)

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gy", tele_builtin.lsp_type_definitions, opts)

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", tele_builtin.lsp_implementations, opts)
        --

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>dl", vim.diagnostic.open_float, opts)

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>db", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        opts.desc = "Show workspace diagnostics"
        keymap.set("n", "<leader>dw", function()
          require("telescope.builtin").diagnostics({
            bufnr = nil, -- 0은 현재 버퍼
            severity = nil, -- nil 이면 모든 심각도 수준
            root_dir = nil, -- nil이면 모든 파일 포함 (전체 워크스페이스)
          })
        end, opts)

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        --

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "See available code actions" -- see available code actions, in visual mode will apply to selection
        keymap.set({ "n", "v" }, "<leader>c", vim.lsp.buf.code_action, opts)

        opts.desc = "Smart rename" -- smart rename, vscode F2
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        vim.keymap.set("n", "<leader>ram", ":delmarks a-zA-Z0-9", { desc = "Clear all marks" })

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end,
    })

    -- LSP 서버가 제공하는 _typescript.organizeImports 명령을 neovim 에 attach
    vim.api.nvim_create_user_command("OrganizeImports", function()
      vim.lsp.buf.execute_command({
        command = "_typescript.organizeImports",
        arguments = {
          vim.api.nvim_buf_get_name(0), -- 현재 열린 파일의 전체 경로를 인자로 전달
        },
        title = "",
      })
    end, { desc = "Organize Imports" })

    -- attach 한 organizeImports 명령에 키매핑
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
      callback = function()
        local opts = { buffer = true, silent = true }
        keymap.set("n", "<leader>oi", ":OrganizeImports<CR>", opts)
      end,
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    mason_lspconfig.setup_handlers({
      -- default handler for installed servers
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      ["svelte"] = function()
        -- configure svelte server
        lspconfig["svelte"].setup({
          capabilities = capabilities,
          on_attach = function(client)
            vim.api.nvim_create_autocmd("BufWritePost", {
              pattern = { "*.js", "*.ts" },
              callback = function(ctx)
                -- Here use ctx.match instead of ctx.file
                client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
              end,
            })
          end,
        })
      end,
      ["emmet_ls"] = function()
        -- configure emmet language server
        lspconfig["emmet_ls"].setup({
          capabilities = capabilities,
          filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
        })
      end,
      ["lua_ls"] = function()
        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        })
      end,
    })
  end,
}
