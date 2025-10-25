-- language server for css, scss, less
return {
  cmd = {
    "vscode-css-language-server",
    "--stdio",
  },
  filetypes = {
    "css",
    -- "scss",
    -- "less",
  },
  root_markers = {
    "package.json",
    ".git",
  },
  settings = {
    css = {
      validate = true, -- find syntax errors, unknown properties, etc
      lint = {
        -- at-rules means rules starting with @
        -- if ignore, ignore unknown at-rules like @tailwind
        unknownAtRules = "ignore",
      },
    },
  },
}
