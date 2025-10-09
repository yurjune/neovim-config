local function organize_imports()
  vim.lsp.buf.code_action({
    context = {
      -- organizes and removes unused imports
      only = { "source.organizeImports" },
      diagnostics = {},
    },
    apply = true,
  })
  vim.notify("Organize imports triggered", vim.log.levels.INFO, { title = "LSP" })
end

local function remove_unused()
  vim.lsp.buf.code_action({
    context = {
      ---@diagnostic disable-next-line: assign-type-mismatch
      only = { "source.removeUnused" },
      diagnostics = {},
    },
    apply = true,
  })
  vim.notify("Remove unused triggered", vim.log.levels.INFO, { title = "LSP" })
end

local function add_missing_imports()
  vim.lsp.buf.code_action({
    context = {
      ---@diagnostic disable-next-line: assign-type-mismatch
      only = { "source.addMissingImports" },
      diagnostics = {},
    },
    apply = true,
  })
  vim.notify("Add Missing imports triggered", vim.log.levels.INFO, { title = "LSP" })
end

local function fix_all()
  vim.lsp.buf.code_action({
    context = {
      -- despite the name, fixes a couple of specific issues: unreachable code, await in non-async functions, incorrectly implemented interface
      only = { "source.fixAll" },
      diagnostics = {},
    },
    apply = true,
  })
  vim.notify("Fix all triggered", vim.log.levels.INFO, { title = "LSP" })
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("ts_ls_group", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if client and client.name == "ts_ls" then
      vim.api.nvim_create_user_command("OrganizeImports", organize_imports, {})
      vim.api.nvim_create_user_command("RemoveUnused", remove_unused, {})
      vim.api.nvim_create_user_command("MissingImports", add_missing_imports, {})
      vim.api.nvim_create_user_command("FixAll", fix_all, {})

      vim.keymap.set("n", "<leader>oi", organize_imports, { desc = "Organize Imports", buffer = ev.buf })
      vim.keymap.set("n", "<leader>ru", remove_unused, { desc = "Remove unused", buffer = ev.buf })
      vim.keymap.set("n", "<leader>mi", add_missing_imports, { desc = "Add missing imports", buffer = ev.buf })
      vim.keymap.set("n", "<leader>fa", fix_all, { desc = "Fix all", buffer = ev.buf })
    end
  end,
})

return {
  cmd = {
    "typescript-language-server",
    "--stdio",
  },
  filetypes = {
    "typescript",
    "javascript",
    "typescriptreact",
    "javascriptreact",
  },
  root_markers = {
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    ".git",
  },
  init_options = {
    preferences = {
      providePrefixAndSuffixTextForRename = false,

      -- Inlay Hints
      includeInlayParameterNameHints = "literals", -- none, literals, all
      includeInlayParameterNameHintsWhenArgumentMatchesName = false, -- show inlay even if argument matches parameter name
      includeInlayFunctionParameterTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayVariableTypeHints = true,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayEnumMemberValueHints = true,

      -- Import settings
      importModuleSpecifierPreference = "shortest", -- shortest, relative, non-relative, project-relative
      -- minimal: remove specifier like /index or .ts
      importModuleSpecifierEnding = "minimal", -- auto, minimal, index
    },
  },
}
