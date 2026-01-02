-- A plugin for edit files like a normal buffer
vim.pack.add({
  {
    src = "https://github.com/stevearc/oil.nvim",
    dependencies = {
      "https://github.com/nvim-tree/nvim-web-devicons",
    },
  },
})
vim.cmd.packadd("oil.nvim")

require("oil").setup({
  default_file_explorer = false,
  keymaps = {
    ["g?"] = { "actions.show_help", mode = "n" },
    ["<CR>"] = "actions.select",
    ["<Tab>"] = "actions.select",
    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
    ["<C-t>"] = { "actions.select", opts = { tab = true } },
    -- ["<C-p>"] = "actions.preview",
    ["<C-c>"] = { "actions.close", mode = "n" },
    ["<C-l>"] = "actions.refresh",
    ["-"] = { "actions.parent", mode = "n" },
    ["<C-p>"] = { "actions.parent", mode = "n" },
    ["_"] = { "actions.open_cwd", mode = "n" },
    ["`"] = { "actions.cd", mode = "n" },
    ["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
    ["gs"] = { "actions.change_sort", mode = "n" },
    ["gx"] = "actions.open_external",
    ["g."] = { "actions.toggle_hidden", mode = "n" },
    ["g\\"] = { "actions.toggle_trash", mode = "n" },
  },
  lsp_file_methods = {
    -- Enable or disable LSP file operations
    enabled = true,
    -- Time to wait for LSP file operations to complete before skipping
    timeout_ms = 1000,
    -- Set to true to autosave buffers that are updated with LSP willRenameFiles
    -- Set to "unmodified" to only save unmodified buffers
    autosave_changes = true,
  },
})

vim.keymap.set("n", "<leader>o", "<cmd>Oil<CR>", { desc = "Open Oil" })
