return {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm", -- fallback when no .clangd on root
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac",
    ".git",
  },
  capabilities = {
    offsetEncoding = { "utf-16" },
  },
  settings = {},
  on_attach = function(client)
    if vim.g.leetcode and vim.g.leetcode_lsp_off then
      client:stop()
      return
    end
  end,
}
