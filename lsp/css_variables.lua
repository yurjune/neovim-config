-- language server for css variables

-- features:
-- jump to css variable definition (var(--primary-color) → --primary-color)
return {
  cmd = {
    "css-variables-language-server",
    "--stdio",
  },
  filetypes = {
    "css",
  },
  root_markers = {
    "package.json",
    ".git",
  },
  settings = {
    cssVariables = {
      lookupFiles = { "**/*.css" },
    },
  },
}
