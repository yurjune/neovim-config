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
