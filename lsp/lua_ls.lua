return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
  },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT", -- Neovim includes LuaJIT
      },
      diagnostics = {
        globals = { "vim", "hs", "_G" },
      },
      workspace = {
        library = {
          -- Enable Neovim API autocompletion (vim.api, vim.fn, etc.)
          -- This can be removed if you use lazydev.nvim plugin
          vim.env.VIMRUNTIME, -- Neovim runtime path
        },
        checkThirdParty = false, -- Third party check popup
      },
      completion = {
        -- Disable: function only → table.insert
        -- Replace: snippet only → table.insert(list, value)
        -- Both: both -> [table.insert] and [table.insert~]
        callSnippet = "Disable",
      },
    },
  },
}
