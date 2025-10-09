local function organize_imports()
  vim.lsp.buf.code_action({
    context = {
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
      only = { "source.removeUnused.ts" },
      diagnostics = {},
    },
    apply = true,
  })
  vim.notify("Remove unused triggered", vim.log.levels.INFO, { title = "LSP" })
end

-- LSP config for ts-ls
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("ts_ls_group", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if client and client.name == "ts_ls" then
      vim.api.nvim_create_user_command("OrganizeImports", organize_imports, {})
      vim.api.nvim_create_user_command("RemoveUnused", remove_unused, {})

      vim.keymap.set("n", "<leader>oi", organize_imports, { desc = "Organize Imports", buffer = ev.buf })
      vim.keymap.set("n", "<leader>ru", remove_unused, { desc = "Remove unused", buffer = ev.buf })
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
