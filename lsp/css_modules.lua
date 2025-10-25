-- language server for css modules

-- features:
-- intellisense for CSS Modules in JS/TS
-- go to definition & find references
return {
  cmd = {
    "cssmodules-language-server",
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
    ".git",
  },
  settings = {},
}
