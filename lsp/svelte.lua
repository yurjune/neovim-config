local svelte_group = vim.api.nvim_create_augroup("svelte_lsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = svelte_group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- Notify Svelte LSP that the file has changed, so that LSP server can update type info and diagnostics
    if client and client.name == "svelte" then
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = svelte_group,
        -- When JS/TS file changes which is imported by Svelte file,
        pattern = { "*.js", "*.ts" },
        callback = function(ctx)
          ---@diagnostic disable-next-line: param-type-mismatch
          client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
        end,
      })
    end
  end,
})

return {
  cmd = {
    -- Mason: svelte-language-server
    "svelteserver",
    "--stdio",
  },
  filetypes = { "svelte" },
  root_markers = {
    "package.json",
    "svelte.config.js",
    ".git",
  },
}
