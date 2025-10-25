return {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  root_markers = { "package.json", ".git" },
  settings = {
    html = {
      validate = {
        scripts = true, -- validate js in script tag
        styles = true, -- validate css in style tag
      },
    },
  },
}
