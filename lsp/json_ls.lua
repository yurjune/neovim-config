return {
  cmd = {
    -- Mason: json-lsp
    "vscode-json-language-server",
    "--stdio",
  },
  filetypes = {
    "json",
    "jsonc",
  },
  root_markers = {
    "package.json",
    ".git",
  },
  settings = {
    json = {
      validate = {
        enable = true,
      },
      format = {
        enable = false,
      },
      schemas = {
        -- JS/TS
        {
          fileMatch = { "package.json" },
          url = "https://json.schemastore.org/package.json",
        },
        {
          fileMatch = { "tsconfig*.json" },
          url = "https://json.schemastore.org/tsconfig.json",
        },
        -- Build/Bundler
        {
          fileMatch = { "vite.config.json" },
          url = "https://json.schemastore.org/vite.json",
        },
        -- Linter/Formatter
        {
          fileMatch = { ".eslintrc", ".eslintrc.json" },
          url = "https://json.schemastore.org/eslintrc.json",
        },
        {
          fileMatch = { ".prettierrc", ".prettierrc.json" },
          url = "https://json.schemastore.org/prettierrc.json",
        },
        -- VSCode
        {
          fileMatch = { "settings.json" },
          url = "https://json.schemastore.org/vscode-settings.json",
        },
        -- CI/CD
        {
          fileMatch = { ".github/workflows/*.json" },
          url = "https://json.schemastore.org/github-workflow.json",
        },
      },
    },
  },
}
