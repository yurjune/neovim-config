-- language server for scss (somesass)

-- features:
-- jump to mixin definition (@include → @mixin)
-- track variable references (find $primary-color definition)
-- find function definitions (@function references)
-- module system (@use, @forward path resolution)
return {
  cmd = {
    "some-sass-language-server",
    "--stdio",
  },
  filetypes = {
    "scss",
    "sass",
  },
  root_markers = {
    "package.json",
    ".git",
  },
  settings = {
    somesass = {
      workspaceFolder = vim.fn.getcwd(), -- scan all SCSS files in workspace
      -- resolve @import, @use, @forward paths
      loadPaths = {
        "node_modules",
      },
      suggestAllFromOpenDocument = true, -- autocomplete for mixin, variable, function
      suggestFromUseOnly = false, -- show @deprecated items
    },
  },
}
